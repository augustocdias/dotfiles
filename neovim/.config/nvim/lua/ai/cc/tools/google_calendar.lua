local handlers = require('ai.cc.utils')
return handlers.create_tool({
    name = 'google_calendar',
    description = 'Query events and details from Google Calendar using gcalcli',
    properties = {
        action = {
            type = 'string',
            description = 'Action to perform: "list_calendars", "agenda", "search", or "list_today"',
        },
        query = {
            type = 'string',
            description = 'Search query for "search" actions',
        },
        days = {
            type = 'integer',
            description = 'Number of days to show for "agenda" action (default: 7)',
        },
        calendar = {
            type = 'string',
            description = 'Specific calendar to query (optional)',
        },
        details = {
            type = 'boolean',
            description = 'Show detailed information (true/false, default: false)',
        },
    },
    required = { 'action' },
    func = function(_, schema_params, _, output_handler)
        local action = schema_params.action

        if not action then
            return output_handler({ status = 'error', error = 'action parameter is required' })
        end

        local cmd_args = { 'gcalcli' }

        if action == 'list_calendars' then
            table.insert(cmd_args, 'list')
        elseif action == 'agenda' then
            local days = schema_params.days or 7
            table.insert(cmd_args, 'agenda')
            table.insert(cmd_args, '--details')
            table.insert(cmd_args, 'all')
            if schema_params.calendar then
                table.insert(cmd_args, '--calendar')
                table.insert(cmd_args, schema_params.calendar)
            end
            table.insert(cmd_args, 'today')
            table.insert(cmd_args, days .. 'd')
        elseif action == 'list_today' then
            table.insert(cmd_args, 'agenda')
            table.insert(cmd_args, '--details')
            table.insert(cmd_args, 'all')
            if schema_params.calendar then
                table.insert(cmd_args, '--calendar')
                table.insert(cmd_args, schema_params.calendar)
            end
            table.insert(cmd_args, 'today')
        elseif action == 'search' then
            if not schema_params.query then
                return output_handler({ status = 'error', error = 'query is required for search action' })
            end

            table.insert(cmd_args, 'search')
            table.insert(cmd_args, '--details')
            table.insert(cmd_args, 'all')
            table.insert(cmd_args, schema_params.query)
            if schema_params.calendar then
                table.insert(cmd_args, '--calendar')
                table.insert(cmd_args, schema_params.calendar)
            end
        else
            return output_handler({
                status = 'error',
                error = 'Invalid action. Use: list_calendars, agenda, search, or list_today',
            })
        end

        vim.system(cmd_args, { text = true }, function(result)
            vim.schedule(function()
                if result.code ~= 0 then
                    local error_msg = 'gcalcli command failed'
                    if result.stderr and result.stderr ~= '' then
                        error_msg = error_msg .. ': ' .. result.stderr
                    elseif result.stdout and result.stdout ~= '' then
                        error_msg = error_msg .. ': ' .. result.stdout
                    end

                    -- Check for authentication errors
                    if
                        result.stdout
                        and (
                            result.stdout:match('Authentication')
                            or result.stdout:match('credentials')
                            or result.stdout:match('OAuth')
                            or result.stdout:match('No credentials')
                            or result.stdout:match('Invalid credentials')
                            or result.stdout:match('Access denied')
                            or result.stdout:match('401')
                        )
                    then
                        error_msg = 'Authentication required. Run: gcalcli init'
                    end

                    -- Check for gcalcli not found
                    if
                        result.stderr
                        and (
                            result.stderr:match('command not found')
                            or result.stderr:match('No such file or directory')
                        )
                    then
                        error_msg = 'gcalcli not installed. Install with: brew install gcalcli'
                    end

                    output_handler({ status = 'error', error = error_msg })
                else
                    local output = result.stdout or ''
                    output_handler({ status = 'success', output = output })
                end
            end)
        end)
    end,

    system_prompt = [[Query and search Google Calendar events using the gcalcli command-line tool. All operations are read-only.

**Available Actions**:
- **list_calendars**: Show all available calendars in your Google account
- **agenda**: Display upcoming events for the next N days (default: 7 days). Use `days` parameter to customize.
- **list_today**: Show all events for today only
- **search**: Search for events by keyword. Requires `query` parameter.

**Optional Parameters**:
- **calendar**: Specify a specific calendar name to query (otherwise queries all calendars)
- **details**: Get detailed information including event descriptions and attendees

Use this tool when you need to:
- Check your schedule for today or upcoming days
- Find specific meetings or events
- See what calendars are available
- Get event details including meeting links and descriptions

All operations are read-only and will not modify your calendar in any way.]],
})
