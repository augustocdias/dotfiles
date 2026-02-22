local M = {}

local Popup = require('nui.popup')
local NuiLine = require('nui.line')
local NuiText = require('nui.text')

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

    table.sort(loaded, function(a, b)
        return a.name < b.name
    end)
    table.sort(pending, function(a, b)
        return a.name < b.name
    end)

    -- Build lines using NuiLine
    local lines = {}

    -- Title
    table.insert(lines, NuiLine({ NuiText(' lze Plugin Status', 'Title') }))
    table.insert(lines, NuiLine({ NuiText('') }))

    -- Loaded section
    table.insert(lines, NuiLine({ NuiText(' Loaded (' .. #loaded .. ')', 'DiagnosticOk') }))

    for _, plugin in ipairs(loaded) do
        table.insert(
            lines,
            NuiLine({
                NuiText('   ✓ ', 'DiagnosticOk'),
                NuiText(plugin.name, 'Normal'),
            })
        )
    end

    table.insert(lines, NuiLine({ NuiText('') }))

    -- Pending section
    table.insert(lines, NuiLine({ NuiText(' Pending (' .. #pending .. ')', 'DiagnosticWarn') }))

    for _, plugin in ipairs(pending) do
        table.insert(
            lines,
            NuiLine({
                NuiText('   ○ ', 'DiagnosticWarn'),
                NuiText(plugin.name, 'Normal'),
            })
        )

        -- Show triggers on separate indented lines
        for _, trigger in ipairs(plugin.triggers) do
            table.insert(
                lines,
                NuiLine({
                    NuiText('       ', 'Normal'),
                    NuiText(trigger.label, 'Comment'),
                    NuiText(': ', 'Comment'),
                    NuiText(trigger.value, trigger.hl),
                })
            )
        end
    end

    -- Help line
    table.insert(lines, NuiLine({ NuiText('') }))
    table.insert(
        lines,
        NuiLine({
            NuiText(' ', 'Comment'),
            NuiText('q', 'Identifier'),
            NuiText(' close', 'Comment'),
        })
    )

    -- Calculate dimensions (capped to viewport)
    local max_width = vim.o.columns - 4
    local max_height = vim.o.lines - 4
    local width = math.min(70, max_width)
    local height = math.min(#lines + 2, 40, max_height)

    -- Calculate centered position
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local popup = Popup({
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
                top = ' lze ',
                top_align = 'center',
            },
        },
        buf_options = {
            modifiable = false,
            readonly = true,
            buftype = 'nofile',
            filetype = 'lze-status',
        },
        win_options = {
            cursorline = true,
            wrap = false,
        },
    })

    popup:mount()

    local buf = popup.bufnr

    -- Render lines
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

    for i, line in ipairs(lines) do
        line:render(buf, -1, i)
    end

    vim.bo[buf].modifiable = false

    -- Keymaps
    popup:map('n', 'q', function()
        popup:unmount()
    end, { silent = true })

    popup:map('n', '<Esc>', function()
        popup:unmount()
    end, { silent = true })
end

return M
