local handlers = require('ai.cc.utils')

-- Function to call Hammerspoon via CLI
local function call_hammerspoon(lua_code, output_handler)
    local cmd = { 'hs', '-c', lua_code }

    vim.system(cmd, { text = true }, function(result)
        vim.schedule(function()
            if result.code == 0 then
                local stdout = result.stdout:gsub('\n$', '')
                output_handler({ status = 'success', data = stdout })
            else
                output_handler({
                    status = 'error',
                    data = 'Hammerspoon CLI error: ' .. (result.stderr or 'Unknown error'),
                })
            end
        end)
    end)
end

return handlers.create_tool({
    name = 'calendar_scheduler',
    description = 'Fetch calendar appointments and manage meeting URL scheduling via Hammerspoon. Never filter out possible duplicates',
    properties = {
        action = {
            type = 'string',
            description = 'Action to perform: "schedule_meetings", "list_scheduled", "cancel_meeting", "cancel_all". Use the `google_calendar` tool to retrieve events',
        },
        meetings = {
            type = 'array',
            description = 'Array of meeting objects with url, datetime, and title for schedule_meetings action',
            items = {
                type = 'object',
                properties = {
                    title = {
                        type = 'string',
                        description = 'Title of the meeting',
                    },
                    url = {
                        type = 'string',
                        description = 'Url of the meeting conference',
                    },
                    datetime = {
                        type = 'string',
                        description = 'Date and time of the meeting',
                    },
                },
                required = { 'title', 'url', 'datetime' },
            },
        },
        meeting_url = {
            type = 'string',
            description = 'Meeting URL to cancel (for cancel_meeting action)',
        },
        datetime = {
            type = 'string',
            description = 'Meeting datetime to cancel (for cancel_meeting action, format: YYYY-MM-DDTHH:MM:SS)',
        },
    },
    required = { 'action' },
    func = function(_, schema_params, _, output_handler)
        local action = schema_params.action

        if not action then
            return output_handler({ status = 'error', data = 'Missing required parameter: action' })
        end

        if action == 'schedule_meetings' then
            local meetings = schema_params.meetings

            if not meetings or #meetings == 0 then
                return output_handler({ status = 'error', data = 'No meetings provided to schedule' })
            end

            local schedule_commands = {}
            local scheduled_count = 0

            for _, meeting in ipairs(meetings) do
                if meeting.url and meeting.datetime and meeting.title then
                    local safe_url = meeting.url:gsub("'", "\\'")
                    local safe_title = meeting.title:gsub("'", "\\'")
                    local safe_datetime = meeting.datetime:gsub("'", "\\'")

                    local lua_cmd = string.format("scheduleUrl('%s', '%s', '%s')", safe_url, safe_datetime, safe_title)
                    table.insert(schedule_commands, lua_cmd)
                    scheduled_count = scheduled_count + 1
                end
            end

            if #schedule_commands > 0 then
                local combined_cmd = table.concat(schedule_commands, '; ')
                call_hammerspoon(combined_cmd, output_handler)
            else
                output_handler({
                    status = 'error',
                    data = 'No valid meetings to schedule (missing url, datetime, or title)',
                })
            end
        elseif action == 'list_scheduled' then
            call_hammerspoon('return listScheduledUrls()', output_handler)
        elseif action == 'cancel_meeting' then
            if not schema_params.meeting_url or not schema_params.datetime then
                output_handler({
                    status = 'error',
                    data = 'Missing required parameters: meeting_url and datetime',
                })
            end

            local safe_url = schema_params.meeting_url:gsub("'", "\\'")
            local safe_datetime = schema_params.datetime:gsub("'", "\\'")
            local lua_cmd = string.format("return cancelScheduledUrl('%s', '%s')", safe_url, safe_datetime)

            call_hammerspoon(lua_cmd, output_handler)
        elseif action == 'cancel_all' then
            call_hammerspoon('return cancelAllScheduledUrls()', output_handler)
        else
            output_handler({
                status = 'error',
                data = 'Unknown action: '
                    .. action
                    .. '. Available actions: schedule_meetings, list_scheduled, cancel_meeting, cancel_all',
            })
        end
    end,
    system_prompt = [[Manage automated meeting URL scheduling through Hammerspoon. This tool integrates with your calendar to automatically open meeting links at the scheduled time.

**Available Actions**:

1. **schedule_meetings**: Schedule one or more meetings to automatically open at their designated times
   - Requires `meetings` array with objects containing:
     - `url`: The meeting conference URL (Zoom, Meet, Teams, etc.)
     - `datetime`: When to open the meeting (ISO format: YYYY-MM-DDTHH:MM:SS)
     - `title`: Meeting title for reference
   - Best practice: Use the `google_calendar` tool to fetch today's events, then schedule them

2. **list_scheduled**: View all currently scheduled meeting URLs and their times

3. **cancel_meeting**: Cancel a specific scheduled meeting
   - Requires `meeting_url` and `datetime` parameters to identify which meeting to cancel

4. **cancel_all**: Cancel all scheduled meetings

**Workflow**: Typically you would:
1. Use `google_calendar` with action "list_today" to get today's meetings
2. Extract meeting URLs and times from the results
3. Use `schedule_meetings` to schedule them for automatic opening
4. Hammerspoon will automatically open the meeting URL in your browser at the scheduled time

Important: Never filter out potential duplicates when scheduling - schedule all meetings as they appear in the calendar.]],
})
