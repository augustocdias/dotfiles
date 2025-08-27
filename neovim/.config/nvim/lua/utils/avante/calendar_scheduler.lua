local wrap_schedule = require('utils').wrap_schedule
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

M.name = 'calendar_scheduler'

M.description =
    'Fetch calendar appointments and manage meeting URL scheduling via Hammerspoon. Never filter out possible duplicates'

M.param = {
    type = 'table',
    fields = {
        {
            name = 'action',
            description = 'Action to perform: "schedule_meetings", "list_scheduled", "cancel_meeting", "cancel_all". Use the `google_calendar` tool to retrieve events',
            type = 'string',
        },
        {
            name = 'meetings',
            description = 'Array of meeting objects with url, datetime, and title for schedule_meetings action',
            type = 'array',
            optional = true,
            items = {
                name = 'meeting_item',
                description = 'Each meeting object',
                type = 'object',
                fields = {
                    {
                        name = 'title',
                        description = 'Title of the meeting',
                        type = 'string',
                    },
                    {
                        name = 'url',
                        description = 'Url of the meeting conference',
                        type = 'string',
                    },
                    {
                        name = 'datetime',
                        description = 'Date and time of the meeting',
                        type = 'string',
                    },
                },
            },
        },
        {
            name = 'meeting_url',
            description = 'Meeting URL to cancel (for cancel_meeting action)',
            type = 'string',
            optional = true,
        },
        {
            name = 'datetime',
            description = 'Meeting datetime to cancel (for cancel_meeting action, format: YYYY-MM-DDTHH:MM:SS)',
            type = 'string',
            optional = true,
        },
    },
}

M.returns = {
    {
        name = 'output',
        description = 'Calendar events data or scheduling result',
        type = 'string',
    },
    {
        name = 'error',
        description = 'Error message if the operation failed',
        type = 'string',
        optional = true,
    },
}

-- Function to call Hammerspoon via CLI
local function call_hammerspoon(lua_code, on_complete)
    local cmd = { 'hs', '-c', lua_code }

    vim.system(cmd, { text = true }, function(result)
        if result.code == 0 then
            local stdout = result.stdout:gsub('\n$', '')
            wrap_schedule(on_complete, stdout)
        else
            wrap_schedule(on_complete, false, 'Hammerspoon CLI error: ' .. (result.stderr or 'Unknown error'))
        end
    end)
end

-- Function to schedule meetings (Phase 2 - with provided URLs)
local function schedule_meetings(meetings, on_complete)
    if not meetings or #meetings == 0 then
        on_complete(false, 'No meetings provided to schedule')
        return
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
        call_hammerspoon(combined_cmd, on_complete)
    else
        on_complete('⚠️ No valid meetings to schedule (missing url, datetime, or title)')
    end
end

-- Main function
function M.func(input, opts)
    local on_complete = opts.on_complete
    local on_log = opts.on_log
    local action = input.action

    if on_log then
        on_log('📆 Calendar Scheduler Action: ' .. (action or 'none'))
    end

    if not action then
        on_complete(false, 'Missing required parameter: action')
        return
    end

    if action == 'schedule_meetings' then
        schedule_meetings(input.meetings, function(result, error)
            if error then
                wrap_schedule(on_complete, false, error)
            else
                wrap_schedule(on_complete, result)
            end
        end)
    elseif action == 'list_scheduled' then
        call_hammerspoon('return listScheduledUrls()', on_complete)
    elseif action == 'cancel_meeting' then
        if not input.meeting_url or not input.datetime then
            wrap_schedule(on_complete, false, 'Missing required parameters: meeting_url and datetime')
            return
        end

        local safe_url = input.meeting_url:gsub("'", "\\'")
        local safe_datetime = input.datetime:gsub("'", "\\'")
        local lua_cmd = string.format("return cancelScheduledUrl('%s', '%s')", safe_url, safe_datetime)

        call_hammerspoon(lua_cmd, on_complete)
    elseif action == 'cancel_all' then
        call_hammerspoon('return cancelAllScheduledUrls()', on_complete)
    else
        on_complete(
            false,
            'Unknown action: '
                .. action
                .. '. Available actions: get_today_events, schedule_meetings, list_scheduled, cancel_meeting, cancel_all, test_connection'
        )
    end
end

return M
