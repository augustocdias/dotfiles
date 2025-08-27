local wrap_schedule = require('utils').wrap_schedule
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

M.name = 'google_calendar'

M.description = 'Query events and details from Google Calendar using gcalcli'

M.param = {
    type = 'table',
    fields = {
        {
            name = 'action',
            description = 'Action to perform: "list_calendars", "agenda", "search", or "list_today"',
            type = 'string',
        },
        {
            name = 'query',
            description = 'Search query for "search" or "when" actions',
            type = 'string',
            optional = true,
        },
        {
            name = 'days',
            description = 'Number of days to show for "agenda" action (default: 7)',
            type = 'number',
            optional = true,
        },
        {
            name = 'calendar',
            description = 'Specific calendar to query (optional)',
            type = 'string',
            optional = true,
        },
        {
            name = 'details',
            description = 'Show detailed information (true/false, default: false)',
            type = 'boolean',
            optional = true,
        },
    },
}

M.returns = {
    {
        name = 'output',
        description = 'Calendar data or formatted output from gcalcli',
        type = 'string',
    },
    {
        name = 'error',
        description = 'Error message if the operation failed',
        type = 'string',
        optional = true,
    },
}

-- Helper function to execute gcalcli command
local function run_gcalcli(cmd_args, on_log, callback)
    -- Split the command arguments properly
    table.insert(cmd_args, 1, 'gcalcli') -- prepend at index 1

    if on_log then
        on_log('📆 Executing: gcalcli ' .. table.concat(cmd_args, ' '))
    end

    vim.system(cmd_args, { text = true }, function(result)
        if result.code ~= 0 then
            local error_msg = 'gcalcli command failed'
            if result.stderr and result.stderr ~= '' then
                error_msg = error_msg .. ': ' .. result.stderr
            elseif result.stdout and result.stdout ~= '' then
                error_msg = error_msg .. ': ' .. result.stdout
            end
            wrap_schedule(callback, false, error_msg)
            return
        end

        local output = result.stdout or ''

        -- Check for authentication errors
        if
            output:match('Authentication')
            or output:match('credentials')
            or output:match('OAuth')
            or output:match('No credentials')
            or output:match('Invalid credentials')
            or output:match('Access denied')
            or output:match('401')
        then
            wrap_schedule(callback, false, 'Authentication required. Run: gcalcli init')
            return
        end

        -- Check for gcalcli not found
        if
            result.stderr and result.stderr:match('command not found')
            or result.stderr:match('No such file or directory')
        then
            wrap_schedule(callback, false, 'gcalcli not installed. Install with: brew install gcalcli')
            return
        end

        wrap_schedule(callback, output)
    end)
end

function M.func(input, opts)
    local on_complete = opts.on_complete
    local on_log = opts.on_log

    if on_log then
        on_log('Action: ' .. input.action)
    end

    local cmd_args = {}

    if input.action == 'list_calendars' then
        table.insert(cmd_args, 'list')
    elseif input.action == 'agenda' then
        local days = input.days or 7
        table.insert(cmd_args, 'agenda')
        table.insert(cmd_args, '--details')
        table.insert(cmd_args, 'all')
        if input.calendar then
            table.insert(cmd_args, '--calendar')
            table.insert(cmd_args, input.calendar)
        end
        table.insert(cmd_args, 'today')
        table.insert(cmd_args, days .. 'd')
    elseif input.action == 'list_today' then
        table.insert(cmd_args, 'agenda')
        table.insert(cmd_args, '--details')
        table.insert(cmd_args, 'all')
        if input.calendar then
            table.insert(cmd_args, '--calendar')
            table.insert(cmd_args, input.calendar)
        end
        table.insert(cmd_args, 'today')
    elseif input.action == 'search' then
        if not input.query then
            on_complete(false, 'query is required for search action')
            return
        end

        table.insert(cmd_args, 'search')
        table.insert(cmd_args, '--details')
        table.insert(cmd_args, 'all')
        table.insert(cmd_args, input.query)
        if input.calendar then
            table.insert(cmd_args, '--calendar')
            table.insert(cmd_args, input.calendar)
        end
    else
        on_complete(false, 'Invalid action. Use: list_calendars, agenda, search, when, or list_today')
        return
    end

    -- Execute the command
    run_gcalcli(cmd_args, on_log, on_complete)
end

return M
