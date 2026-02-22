-- Plugin update checker for Nix-managed Neovim plugins
--
-- NOTE: This script assumes all plugins are hosted on GitHub.
-- If you add plugins from other sources (GitLab, Codeberg, etc.),
-- you will need to modify the fetch_plugin_updates() function
-- to handle different API endpoints.

-- Config
local DOTFILES_PATH = vim.fn.expand('~/.dotfiles/home/neovim')
local PLUGINS_JSON = DOTFILES_PATH .. '/plugins.json'
local PLUGINS_NIX = DOTFILES_PATH .. '/plugins.nix'
local MAX_NOTIFICATION_ITEMS = 5

-- Cache (persists in module scope)
local cache = {
    status = 'idle', -- 'idle' | 'fetching' | 'done'
    completed = 0,
    total = 0,
    results = {}, -- keyed by plugin name
}

-- UI state
local ui = {
    popup = nil,
    update_fn = nil, -- function to call when cache updates
}

-- Parse plugins.json
local function get_plugin_sources()
    local file = io.open(PLUGINS_JSON, 'r')
    if not file then
        return nil
    end
    local content = file:read('*a')
    file:close()
    local ok, result = pcall(vim.json.decode, content)
    if not ok then
        return nil
    end
    return result
end

-- Parse plugins.nix for current revs
local function get_current_revs()
    local file = io.open(PLUGINS_NIX, 'r')
    if not file then
        return nil
    end
    local content = file:read('*a')
    file:close()

    local revs = {}
    -- Match: plugin-name = "commit-sha";
    for name, rev in content:gmatch('([%w_%-]+)%s*=%s*"([a-f0-9]+)";') do
        revs[name] = rev
    end
    return revs
end

-- Check if rev looks like a tag (vX.Y.Z pattern) vs branch name
local function is_tag(rev)
    return rev:match('^v?%d+%.%d+') ~= nil
end

-- Fetch updates for a single plugin (async)
local function fetch_plugin_updates(plugin, current_rev, callback)
    local owner = plugin.owner
    local repo = plugin.repo
    local rev = plugin.rev -- branch or tag from plugins.json

    local function on_error(err)
        callback({
            status = 'error',
            current_rev = current_rev,
            error = err,
        })
    end

    if is_tag(rev) then
        -- Tag-based: first get latest release tag, then compare
        local cmd = { 'gh', 'api', string.format('repos/%s/%s/releases/latest', owner, repo) }
        vim.system(cmd, { text = true }, function(result)
            if result.code ~= 0 then
                on_error('Failed to fetch latest release')
                return
            end

            local ok, release = pcall(vim.json.decode, result.stdout)
            if not ok then
                on_error('Failed to parse release JSON')
                return
            end

            local latest_tag = release.tag_name
            if latest_tag == rev then
                -- Up to date
                callback({
                    status = 'up-to-date',
                    current_rev = current_rev,
                    latest_rev = current_rev,
                    commits = {},
                    last_updated = release.published_at and release.published_at:sub(1, 10) or nil,
                })
            else
                -- Has updates - get commits between tags
                local compare_cmd =
                    { 'gh', 'api', string.format('repos/%s/%s/compare/%s...%s', owner, repo, rev, latest_tag) }
                vim.system(compare_cmd, { text = true }, function(cmp_result)
                    if cmp_result.code ~= 0 then
                        -- Fallback: just report update available without commit details
                        callback({
                            status = 'updates',
                            current_rev = current_rev,
                            latest_rev = latest_tag,
                            commits = {},
                            latest_tag = latest_tag,
                        })
                        return
                    end

                    local cok, comparison = pcall(vim.json.decode, cmp_result.stdout)
                    if not cok then
                        callback({
                            status = 'updates',
                            current_rev = current_rev,
                            latest_rev = latest_tag,
                            commits = {},
                            latest_tag = latest_tag,
                        })
                        return
                    end

                    callback({
                        status = 'updates',
                        current_rev = current_rev,
                        latest_rev = latest_tag,
                        commits = comparison.commits or {},
                        latest_tag = latest_tag,
                    })
                end)
            end
        end)
    else
        -- Branch-based: compare current SHA with branch HEAD
        local cmd = { 'gh', 'api', string.format('repos/%s/%s/compare/%s...%s', owner, repo, current_rev, rev) }
        vim.system(cmd, { text = true }, function(result)
            if result.code ~= 0 then
                on_error('Failed to fetch comparison: ' .. (result.stderr or 'unknown error'))
                return
            end

            local ok, comparison = pcall(vim.json.decode, result.stdout)
            if not ok then
                on_error('Failed to parse comparison JSON')
                return
            end

            local commits = comparison.commits or {}
            if #commits == 0 then
                -- Up to date - fetch last commit date
                local commit_cmd = { 'gh', 'api', string.format('repos/%s/%s/commits/%s', owner, repo, current_rev) }
                vim.system(commit_cmd, { text = true }, function(commit_result)
                    local last_updated = nil
                    if commit_result.code == 0 then
                        local cok, commit_data = pcall(vim.json.decode, commit_result.stdout)
                        if cok and commit_data.commit and commit_data.commit.committer then
                            last_updated = commit_data.commit.committer.date
                            if last_updated then
                                last_updated = last_updated:sub(1, 10)
                            end
                        end
                    end
                    callback({
                        status = 'up-to-date',
                        current_rev = current_rev,
                        latest_rev = current_rev,
                        commits = {},
                        last_updated = last_updated,
                    })
                end)
            else
                callback({
                    status = 'updates',
                    current_rev = current_rev,
                    latest_rev = commits[#commits].sha,
                    commits = commits,
                })
            end
        end)
    end
end

-- Called when all fetches complete
local function on_fetch_complete()
    local updates = {}
    for name, result in pairs(cache.results) do
        if result.status == 'updates' then
            table.insert(updates, {
                name = name,
                commits = #result.commits,
                latest_tag = result.latest_tag,
            })
        end
    end

    if #updates == 0 then
        return -- No notification if all up-to-date
    end

    -- Sort by commit count descending
    table.sort(updates, function(a, b)
        return a.commits > b.commits
    end)

    -- Build notification message
    local lines = {}
    for i, u in ipairs(updates) do
        if i > MAX_NOTIFICATION_ITEMS then
            table.insert(lines, string.format('  +%d more...', #updates - MAX_NOTIFICATION_ITEMS))
            break
        end
        local suffix = u.latest_tag and (' -> ' .. u.latest_tag) or string.format(' (%d commits)', u.commits)
        table.insert(lines, '  * ' .. u.name .. suffix)
    end
    table.insert(lines, '')
    table.insert(lines, 'Run :CheckPluginUpdates for details')

    vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, {
        title = string.format('Plugin Updates Available (%d)', #updates),
    })
end

-- Start fetching all plugin updates
local function fetch_all()
    if cache.status == 'fetching' then
        return -- Already in progress
    end

    local sources = get_plugin_sources()
    local revs = get_current_revs()

    if not sources or not revs then
        vim.notify('Failed to read plugin files', vim.log.levels.ERROR)
        return
    end

    cache = {
        status = 'fetching',
        completed = 0,
        total = vim.tbl_count(sources),
        results = {},
    }

    local pending = cache.total

    for name, plugin in pairs(sources) do
        local current_rev = revs[name]
        if not current_rev then
            cache.completed = cache.completed + 1
            cache.results[name] = {
                status = 'error',
                error = 'No revision found in plugins.nix',
            }
            pending = pending - 1
            if pending == 0 then
                cache.status = 'done'
                on_fetch_complete()
            end
        else
            fetch_plugin_updates(plugin, current_rev, function(result)
                vim.schedule(function()
                    cache.completed = cache.completed + 1
                    cache.results[name] = result
                    pending = pending - 1

                    -- Update UI if open
                    if ui.update_fn then
                        ui.update_fn()
                    end

                    if pending == 0 then
                        cache.status = 'done'
                        -- Update UI one final time to hide progress bar
                        if ui.update_fn then
                            ui.update_fn()
                        end
                        -- Only show notification if popup is not open
                        if not ui.popup or not vim.api.nvim_win_is_valid(ui.popup.winid) then
                            on_fetch_complete()
                        end
                    end
                end)
            end)
        end
    end
end

-- Render progress bar
local function render_progress()
    local NuiLine = require('nui.line')
    local NuiText = require('nui.text')
    local width = 40
    local pct = cache.total > 0 and (cache.completed / cache.total) or 0
    local filled = math.floor(pct * width)
    local empty = width - filled

    local bar = string.rep('█', filled) .. string.rep('░', empty)
    local text = string.format(' %d/%d ', cache.completed, cache.total)

    return NuiLine({ NuiText(bar, 'DiagnosticInfo'), NuiText(text, 'Comment') })
end

-- Check if a commit message indicates a breaking change (conventional commits)
local function is_breaking_change(message)
    -- Match: feat!, fix!, refactor!, etc. or BREAKING CHANGE:
    return message:match('^%w+!:') ~= nil
        or message:match('^%w+%(.+%)!:') ~= nil
        or message:match('BREAKING CHANGE') ~= nil
end

-- Render the content
local function render_content(buf)
    local NuiLine = require('nui.line')
    local NuiText = require('nui.text')
    local lines = {}

    -- Title
    local title_line = NuiLine({ NuiText(' Plugin Updates', 'Title') })
    table.insert(lines, title_line)
    table.insert(lines, NuiLine({ NuiText('') }))

    -- Progress bar if still fetching
    if cache.status == 'fetching' then
        table.insert(lines, render_progress())
        table.insert(lines, NuiLine({ NuiText('') }))
    end

    -- Sort plugins: updates first (by commit count desc), then up-to-date (alphabetically), then errors
    local sorted = {}
    for name, result in pairs(cache.results) do
        table.insert(sorted, { name = name, result = result })
    end
    table.sort(sorted, function(a, b)
        local a_status = a.result.status
        local b_status = b.result.status
        -- updates first
        if a_status == 'updates' and b_status ~= 'updates' then
            return true
        end
        if b_status == 'updates' and a_status ~= 'updates' then
            return false
        end
        -- within updates, sort by commit count desc
        if a_status == 'updates' and b_status == 'updates' then
            return #a.result.commits > #b.result.commits
        end
        -- up-to-date before errors
        if a_status == 'up-to-date' and b_status == 'error' then
            return true
        end
        if b_status == 'up-to-date' and a_status == 'error' then
            return false
        end
        -- alphabetically within same status
        return a.name < b.name
    end)

    for _, item in ipairs(sorted) do
        local name = item.name
        local result = item.result

        if result.status == 'updates' then
            local commit_count = #result.commits
            local suffix = result.latest_tag and (' -> ' .. result.latest_tag)
                or string.format(' (%d commits)', commit_count)

            local header_line = NuiLine({
                NuiText('  ↑ ', 'DiagnosticWarn'),
                NuiText(name, 'Normal'),
                NuiText(suffix, 'Comment'),
            })
            table.insert(lines, header_line)

            -- Show commits
            for _, commit in ipairs(result.commits) do
                local msg = commit.commit and commit.commit.message or ''
                -- Get first line only
                msg = msg:match('^[^\n]+') or msg
                -- Truncate if too long
                if #msg > 60 then
                    msg = msg:sub(1, 57) .. '...'
                end

                local sha_short = (commit.sha or ''):sub(1, 7)
                local msg_hl = is_breaking_change(msg) and 'DiagnosticError' or 'Comment'

                local commit_line = NuiLine({
                    NuiText('      ', 'Normal'),
                    NuiText(sha_short, 'Identifier'),
                    NuiText(' ', 'Normal'),
                    NuiText(msg, msg_hl),
                })
                table.insert(lines, commit_line)
            end
        elseif result.status == 'up-to-date' then
            local date_str = result.last_updated and (' (' .. result.last_updated .. ')') or ''
            local line = NuiLine({
                NuiText('  ✓ ', 'DiagnosticOk'),
                NuiText(name, 'Normal'),
                NuiText(date_str, 'Comment'),
            })
            table.insert(lines, line)
        elseif result.status == 'error' then
            local line = NuiLine({
                NuiText('  ✗ ', 'DiagnosticError'),
                NuiText(name, 'Normal'),
                NuiText(' - ' .. (result.error or 'unknown error'), 'DiagnosticError'),
            })
            table.insert(lines, line)
        end
    end

    -- Help line
    table.insert(lines, NuiLine({ NuiText('') }))
    table.insert(
        lines,
        NuiLine({
            NuiText(' ', 'Comment'),
            NuiText('R', 'Identifier'),
            NuiText(' refresh  ', 'Comment'),
            NuiText('q', 'Identifier'),
            NuiText(' close', 'Comment'),
        })
    )

    -- Render to buffer
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

    for i, line in ipairs(lines) do
        line:render(buf, -1, i)
    end

    vim.bo[buf].modifiable = false
end

-- Show the UI
local function show()
    local Popup = require('nui.popup')
    -- If already open, just focus it
    if ui.popup and vim.api.nvim_win_is_valid(ui.popup.winid) then
        vim.api.nvim_set_current_win(ui.popup.winid)
        return
    end

    -- Calculate dimensions (80% width, 70% height, capped to viewport)
    local max_width = vim.o.columns - 4
    local max_height = vim.o.lines - 4 -- Leave room for cmdline and some padding
    local width = math.min(math.floor(vim.o.columns * 0.8), max_width)
    local height = math.min(math.floor(vim.o.lines * 0.7), max_height)

    -- Calculate centered position
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    ui.popup = Popup({
        relative = 'editor',
        position = {
            row = row,
            col = col,
        },
        size = {
            width = width,
            height = height,
        },
        enter = true,
        focusable = true,
        border = {
            style = 'rounded',
            text = {
                top = ' Plugin Updates ',
                top_align = 'center',
            },
        },
        buf_options = {
            modifiable = false,
            readonly = true,
            buftype = 'nofile',
            filetype = 'plugin-updates',
        },
        win_options = {
            cursorline = true,
            wrap = false,
        },
    })

    ui.popup:mount()

    local buf = ui.popup.bufnr

    -- Update function for live updates
    ui.update_fn = function()
        if ui.popup and vim.api.nvim_buf_is_valid(buf) then
            render_content(buf)
        end
    end

    -- Initial render
    render_content(buf)

    -- Keymaps
    ui.popup:map('n', 'q', function()
        ui.popup:unmount()
        ui.popup = nil
        ui.update_fn = nil
    end, { silent = true })

    ui.popup:map('n', '<Esc>', function()
        ui.popup:unmount()
        ui.popup = nil
        ui.update_fn = nil
    end, { silent = true })

    ui.popup:map('n', 'R', function()
        -- Reset cache and re-fetch
        cache = {
            status = 'idle',
            completed = 0,
            total = 0,
            results = {},
        }
        render_content(buf)
        fetch_all()
    end, { silent = true })

    -- Clean up on window close
    ui.popup:on('WinClosed', function()
        ui.popup = nil
        ui.update_fn = nil
    end)
end

return {
    'plugin-updates',
    event = 'DeferredUIEnter',
    load = function() end,
    after = function()
        vim.api.nvim_create_user_command('CheckPluginUpdates', show, {
            desc = 'Check for Neovim plugin updates',
        })
        fetch_all()
    end,
}
