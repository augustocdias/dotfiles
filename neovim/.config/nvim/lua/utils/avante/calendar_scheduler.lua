local wrap_schedule = require('utils').wrap_schedule
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

M.name = 'calendar_scheduler'

M.description = 'Fetch calendar appointments and manage meeting URL scheduling via Hammerspoon'

M.param = {
    type = 'table',
    fields = {
        {
            name = 'action',
            description = 'Action to perform: "get_today_events", "schedule_meetings", "list_scheduled", "cancel_meeting", "cancel_all"',
            type = 'string',
        },
        {
            name = 'calendar',
            description = 'Calendar name to fetch events from (default: "Work")',
            type = 'string',
            optional = true,
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

-- Function to get today's calendar events (Phase 1 - no URL extraction)
local function get_today_events(calendar_name, on_log, on_complete)
    local safe_calendar = calendar_name or 'Work'

    -- Get today's events using AppleScript
    local script = string.format(
        [[
set calendarFilter to "%s"

tell application "Calendar"
	set today to (current date)
	set tomorrow to today + days
	set time of tomorrow to 0

	set eventList to {}

	set calendarList to every calendar
	set calendarList to (calendars whose name is calendarFilter)

	repeat with cal in calendarList
		try
			set todaysEvents to (events of cal whose start date ≥ today and start date < tomorrow)

			repeat with e in todaysEvents
				-- Batch fetch all properties in one AppleEvent:
				set {startTime, endTime, eventTitle, eventLocation, eventDescription} ¬
					to {start date, end date, summary, location, description} of e

				if eventLocation is missing value then set eventLocation to "None"
				if eventDescription is missing value then set eventDescription to "Empty"

				set end of eventList to (eventTitle & "|" & (startTime as string) & "|" & (endTime as string) & "|" & eventLocation & "|" & eventDescription)
			end repeat
		end try
	end repeat
end tell

return my join(eventList, "||")

on join(lst, delim)
	set oldTIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delim
	set t to lst as string
	set AppleScript's text item delimiters to oldTIDs
	return t
end join
    ]],
        safe_calendar
    )

    vim.system({ 'osascript', '-e', script }, { text = true }, function(result)
        if result.code ~= 0 then
            on_complete(false, 'Failed to fetch calendar events: ' .. (result.stderr or 'Unknown error'))
            return
        end

        local events_data = result.stdout:gsub('\n', '')
        if events_data == '' then
            on_complete('📅 No calendar events found for today in "' .. safe_calendar .. '" calendar.')
            return
        end

        -- Parse events and return structured data
        local events = vim.split(events_data, '||')
        local total_events = 0
        local output = "📅 Today's Calendar Events (" .. safe_calendar .. '):\n\n'
        local events_json = {}

        for _, event_str in ipairs(events) do
            if event_str ~= '' then
                local parts = vim.split(event_str, '|')
                if #parts >= 5 then
                    local title = parts[1]
                    local start_time_str = parts[2]
                    local end_time_str = parts[3]
                    local location = parts[4]
                    local description = parts[5]

                    total_events = total_events + 1

                    -- Extract time for display
                    local hour, min = start_time_str:match('(%d+):(%d+)')
                    if hour and min then
                        local today = os.date('*t')
                        local iso_datetime = string.format(
                            '%04d-%02d-%02dT%02d:%02d:00',
                            today.year,
                            today.month,
                            today.day,
                            tonumber(hour),
                            tonumber(min)
                        )

                        output = output .. string.format('• %s (%s:%s)\n', title, hour, min)

                        if location ~= '' then
                            output = output .. string.format('  📍 %s\n', location)
                        end

                        if description ~= '' then
                            output = output .. string.format('  📝 %s\n', description)
                        end

                        output = output .. '\n'

                        -- Store event data for potential scheduling
                        table.insert(events_json, {
                            title = title,
                            datetime = iso_datetime,
                            location = location,
                            description = description,
                            start_time_str = start_time_str,
                            end_time_str = end_time_str,
                        })
                    end
                end
            end
        end

        local count_events = string.format('📊 Total: %d events found', total_events)
        on_log(count_events)

        output = output .. count_events

        -- Return both human-readable and structured data
        local response = {
            summary = output,
            events = events_json,
            total = total_events,
        }

        on_complete(vim.json.encode(response))
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

    if action == 'get_today_events' then
        get_today_events(input.calendar, on_log, function(result, error)
            if error then
                wrap_schedule(on_complete, false, error)
            else
                wrap_schedule(on_complete, result)
            end
        end)
    elseif action == 'schedule_meetings' then
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
