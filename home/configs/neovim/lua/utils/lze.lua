local M = {}

local function format_keys(keys)
    if type(keys) == 'string' then
        return keys
    end
    if type(keys) ~= 'table' then
        return ''
    end
    local result = {}
    for _, k in ipairs(keys) do
        if type(k) == 'string' then
            table.insert(result, k)
        elseif type(k) == 'table' then
            table.insert(result, k[1] or k.lhs or '?')
        end
    end
    return table.concat(result, ' ')
end

local function format_list(value)
    if type(value) == 'table' then
        return table.concat(value, ', ')
    end
    return tostring(value)
end

--- Show a floating window with lze plugin status
function M.show_status()
    local ok, lze = pcall(require, 'lze')
    if not ok then
        vim.notify('lze not available', vim.log.levels.ERROR)
        return
    end

    local state = -lze.state -- get a snapshot of the state
    local loaded = {}
    local pending = {}

    for name, value in pairs(state) do
        if value == false then
            table.insert(loaded, { name = name })
        elseif type(value) == 'table' then
            local triggers = {}
            if value.event then
                table.insert(triggers, { label = 'event', value = format_list(value.event), hl = 'Type' })
            end
            if value.cmd then
                table.insert(triggers, { label = 'cmd', value = format_list(value.cmd), hl = 'Function' })
            end
            if value.keys then
                table.insert(triggers, { label = 'keys', value = format_keys(value.keys), hl = 'String' })
            end
            if value.ft then
                table.insert(triggers, { label = 'ft', value = format_list(value.ft), hl = 'Keyword' })
            end
            if value.dep_of then
                table.insert(triggers, { label = 'dep_of', value = format_list(value.dep_of), hl = 'Special' })
            end
            if value.on_plugin then
                table.insert(triggers, { label = 'on_plugin', value = format_list(value.on_plugin), hl = 'Special' })
            end
            if value.on_require then
                table.insert(triggers, { label = 'on_require', value = format_list(value.on_require), hl = 'Include' })
            end
            table.insert(pending, { name = name, triggers = triggers })
        end
    end

    table.sort(loaded, function(a, b) return a.name < b.name end)
    table.sort(pending, function(a, b) return a.name < b.name end)

    local lines = {}
    local highlights = {} -- { line, col_start, col_end, hl_group }

    -- Title
    table.insert(lines, ' lze Plugin Status')
    table.insert(highlights, { #lines - 1, 0, -1, 'Title' })
    table.insert(lines, '')

    -- Loaded section
    local loaded_header = ' Loaded (' .. #loaded .. ')'
    table.insert(lines, loaded_header)
    table.insert(highlights, { #lines - 1, 0, -1, 'DiagnosticOk' })

    for _, plugin in ipairs(loaded) do
        local line = '   ✓ ' .. plugin.name
        table.insert(lines, line)
        table.insert(highlights, { #lines - 1, 3, 5, 'DiagnosticOk' })
        table.insert(highlights, { #lines - 1, 5, #line, 'Normal' })
    end

    table.insert(lines, '')

    -- Pending section
    local pending_header = ' Pending (' .. #pending .. ')'
    table.insert(lines, pending_header)
    table.insert(highlights, { #lines - 1, 0, -1, 'DiagnosticWarn' })

    for _, plugin in ipairs(pending) do
        local line = '   ○ ' .. plugin.name
        table.insert(lines, line)
        table.insert(highlights, { #lines - 1, 3, 5, 'DiagnosticWarn' })
        table.insert(highlights, { #lines - 1, 5, #line, 'Normal' })

        -- Show triggers on separate indented lines
        for _, trigger in ipairs(plugin.triggers) do
            local trigger_line = '       ' .. trigger.label .. ': ' .. trigger.value
            table.insert(lines, trigger_line)
            local label_end = 7 + #trigger.label
            table.insert(highlights, { #lines - 1, 7, label_end, 'Comment' })
            table.insert(highlights, { #lines - 1, label_end + 2, #trigger_line, trigger.hl })
        end
    end

    -- Create floating window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Apply highlights
    local ns = vim.api.nvim_create_namespace('lze_status')
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(buf, ns, hl[4], hl[1], hl[2], hl[3])
    end

    vim.bo[buf].modifiable = false
    vim.bo[buf].buftype = 'nofile'

    local width = 70
    local height = math.min(#lines + 2, 40)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = ' lze ',
        title_pos = 'center',
    })

    -- Close on q or Esc
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

return M
