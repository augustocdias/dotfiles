local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

local json_decode_opts = { luanil = { object = true, array = true } }

M.name = 'activitywatch'

M.description = 'Query ActivityWatch data for productivity analytics and time tracking'

M.param = {
    type = 'table',
    fields = {
        {
            name = 'action',
            description = 'Action to perform: "buckets", "today", "last_workday", "window_activity", "events", "query"',
            type = 'string',
        },
        {
            name = 'bucket_id',
            description = 'Bucket ID for "events" action (e.g., "aw-watcher-window_hostname")',
            type = 'string',
            optional = true,
        },
        {
            name = 'start_time',
            description = 'Start time in ISO format (e.g., "2024-08-25T00:00:00")',
            type = 'string',
            optional = true,
        },
        {
            name = 'end_time',
            description = 'End time in ISO format (e.g., "2024-08-25T23:59:59")',
            type = 'string',
            optional = true,
        },
        {
            name = 'limit',
            description = 'Maximum number of events to return (default: 10)',
            type = 'integer',
            optional = true,
        },
        {
            name = 'query',
            description = 'Custom ActivityWatch query string (for "query" action)',
            type = 'string',
            optional = true,
        },
    },
}

M.returns = {
    {
        name = 'output',
        description = 'ActivityWatch data or formatted output',
        type = 'string',
    },
    {
        name = 'error',
        description = 'Error message if the operation failed',
        type = 'string',
        optional = true,
    },
}

-- ActivityWatch configuration
local AW_CONFIG = {
    host = 'localhost',
    port = 5600,
    api_version = '0',
}

-- Utility function to get the current hostname
local function get_hostname()
    local handle = io.popen('hostname')
    local hostname = handle:read('*a'):gsub('\n', '')
    handle:close()
    return hostname
end

-- Build API URL
local function build_url(endpoint)
    return string.format('http://%s:%s/api/%s%s', AW_CONFIG.host, AW_CONFIG.port, AW_CONFIG.api_version, endpoint)
end

-- Execute HTTP request using plenary.curl (consistent with other tools)
local function http_request(url, method, data, on_complete)
    local curl = require('plenary.curl')
    method = method or 'GET'

    local opts = {
        url = url,
        method = method:lower(),
        timeout = 5000, -- 5 seconds timeout
    }

    if data then
        opts.headers = {
            ['Content-Type'] = 'application/json',
        }
        opts.body = vim.json.encode(data)
    end

    local response = curl.request(opts)

    if not response then
        on_complete(false, 'HTTP request failed: No response received')
        return
    end

    if response.status >= 400 then
        on_complete(
            false,
            'HTTP request failed with status ' .. response.status .. ': ' .. (response.body or 'No error message')
        )
        return
    end

    -- Try to parse JSON response
    if response.body and response.body ~= '' then
        local success, parsed = pcall(vim.json.decode, response.body, json_decode_opts)
        if success then
            on_complete(parsed)
        else
            -- Return raw response if JSON parsing fails
            on_complete(response.body)
        end
    else
        on_complete({}) -- Empty response is valid for some operations
    end
end

-- Get all available buckets
local function get_buckets(on_complete)
    local url = build_url('/buckets/')
    http_request(url, 'GET', nil, function(result, error)
        if error then
            on_complete(false, error)
        else
            on_complete(result)
        end
    end)
end

-- Get events from a specific bucket
local function get_events(bucket_id, params, on_complete)
    params = params or {}

    local query_params = {}
    if params.limit then
        table.insert(query_params, 'limit=' .. params.limit)
    end
    if params.start then
        table.insert(query_params, 'start=' .. params.start)
    end
    if params['end'] then
        table.insert(query_params, 'end=' .. params['end'])
    end

    local query_string = ''
    if #query_params > 0 then
        query_string = '?' .. table.concat(query_params, '&')
    end

    local url = build_url('/buckets/' .. bucket_id .. '/events' .. query_string)
    http_request(url, 'GET', nil, function(result, error)
        if error then
            on_complete(false, error)
        else
            on_complete(result)
        end
    end)
end

-- Execute a custom query
local function execute_query(query_data, on_complete)
    local url = build_url('/query/')
    http_request(url, 'POST', query_data, function(result, error)
        if error then
            on_complete(false, error)
        else
            on_complete(result)
        end
    end)
end

-- Get canonical events (processed activity data like the web UI)
local function get_canonical_events(start_time, end_time, on_complete)
    local hostname = get_hostname()

    -- Build canonical query as single string with semicolon-separated statements
    local query_string = string.format(
        'events = flood(query_bucket("aw-watcher-window_%s")); '
            .. 'afk_events = flood(query_bucket("aw-watcher-afk_%s")); '
            .. 'not_afk = filter_keyvals(afk_events, "status", ["not-afk"]); '
            .. 'events = filter_period_intersect(events, not_afk); '
            .. 'events = merge_events_by_keys(events, ["app"]); '
            .. 'RETURN = sort_by_duration(events);',
        hostname,
        hostname
    )

    local query_data = {
        query = { query_string }, -- Array with single complete query string
        timeperiods = { string.format('%s/%s', start_time, end_time) },
    }

    execute_query(query_data, on_complete)
end

-- Utility function to calculate previous workday
local function get_previous_workday(date_timestamp)
    local date_table = os.date('*t', date_timestamp or os.time())
    local weekday = date_table.wday -- 1=Sunday, 2=Monday, ..., 7=Saturday

    -- Calculate days to subtract to get to previous workday
    local days_back
    if weekday == 1 then -- Sunday
        days_back = 2 -- Go back to Friday
    elseif weekday == 2 then -- Monday
        days_back = 3 -- Go back to Friday
    else -- Tuesday-Saturday
        days_back = 1 -- Go back one day
    end

    return date_timestamp - (days_back * 24 * 60 * 60)
end

-- Get today's activity summary
local function get_today_summary(on_complete)
    local today = os.date('%Y-%m-%dT00:00:00')
    local tomorrow = os.date('%Y-%m-%dT00:00:00', os.time() + 24 * 60 * 60)

    get_canonical_events(today, tomorrow, function(result, error)
        if error then
            on_complete(false, error)
            return
        end

        -- Format the results
        local summary = "📊 Today's Activity Summary:\n\n"
        local total_time = 0

        if result and result[1] and #result[1] > 0 then
            for _, event in ipairs(result[1]) do
                local duration_hours = event.duration / 3600
                total_time = total_time + duration_hours

                local app_name = event.data.app or 'Unknown'
                summary = summary .. string.format('• %s: %.1f hours\n', app_name, duration_hours)
            end

            summary = summary .. string.format('\n📈 Total active time: %.1f hours', total_time)
        else
            summary = summary .. 'No activity data found for today.'
        end

        on_complete(summary)
    end)
end

-- Get last workday's activity summary
local function get_last_workday_summary(on_complete)
    local now = os.time()
    local last_workday_timestamp = get_previous_workday(now)

    local start_time = os.date('%Y-%m-%dT00:00:00', last_workday_timestamp)
    local end_time = os.date('%Y-%m-%dT23:59:59', last_workday_timestamp)
    local day_name = os.date('%A, %B %d', last_workday_timestamp)

    get_canonical_events(start_time, end_time, function(result, error)
        if error then
            on_complete(false, error)
            return
        end

        -- Format the results
        local summary = string.format('📊 Last Workday Summary (%s):\n\n', day_name)
        local total_time = 0

        if result and result[1] and #result[1] > 0 then
            for _, event in ipairs(result[1]) do
                local duration_hours = event.duration / 3600
                total_time = total_time + duration_hours

                local app_name = event.data.app or 'Unknown'
                summary = summary .. string.format('• %s: %.1f hours\n', app_name, duration_hours)
            end

            summary = summary .. string.format('\n📈 Total active time: %.1f hours', total_time)
        else
            summary = summary .. 'No activity data found for this day.'
        end

        on_complete(summary)
    end)
end

-- Get window activity for a specific time range
local function get_window_activity(start_time, end_time, on_complete)
    local hostname = get_hostname()
    local bucket_id = 'aw-watcher-window_' .. hostname

    local params = {
        start = start_time,
        ['end'] = end_time,
        limit = 1000,
    }

    get_events(bucket_id, params, function(result, error)
        if error then
            on_complete(false, error)
            return
        end

        local summary = string.format('🪟 Window Activity (%s to %s):\n\n', start_time, end_time)

        if result and #result > 0 then
            -- Group by application
            local app_time = {}

            for _, event in ipairs(result) do
                local app = event.data.app or 'Unknown'
                local duration = event.duration or 0

                app_time[app] = (app_time[app] or 0) + duration
            end

            -- Sort by time spent
            local sorted_apps = {}
            for app, time in pairs(app_time) do
                table.insert(sorted_apps, { app = app, time = time })
            end

            table.sort(sorted_apps, function(a, b)
                return a.time > b.time
            end)

            for _, item in ipairs(sorted_apps) do
                local hours = item.time / 3600
                summary = summary .. string.format('• %s: %.1f hours\n', item.app, hours)
            end
        else
            summary = summary .. 'No window activity found for this time range.'
        end

        on_complete(summary)
    end)
end

-- Main tool function
function M.func(input, opts)
    local on_complete = opts.on_complete
    local on_log = opts.on_log
    local action = input.action

    if on_log then
        on_log('📋ActivityWatch Action: ' .. (action or 'none'))
    end

    if not action then
        on_complete(false, 'Missing required parameter: action')
        return
    end

    if action == 'buckets' then
        get_buckets(function(result, error)
            if error then
                on_complete(false, error)
            else
                local output = '📦 Available ActivityWatch Buckets:\n\n'
                for bucket_id, bucket_info in pairs(result) do
                    output = output .. string.format('• %s\n', bucket_id)
                    output = output .. string.format('  Type: %s\n', bucket_info.type or 'unknown')
                    output = output .. string.format('  Hostname: %s\n', bucket_info.hostname or 'unknown')
                    output = output .. string.format('  Created: %s\n\n', bucket_info.created or 'unknown')
                end
                on_complete(output, nil)
            end
        end)
    elseif action == 'today' then
        get_today_summary(function(result, error)
            if error then
                on_complete(false, error)
            else
                on_complete(result, nil)
            end
        end)
    elseif action == 'last_workday' then
        get_last_workday_summary(function(result, error)
            if error then
                on_complete(false, error)
            else
                on_complete(result, nil)
            end
        end)
    elseif action == 'window_activity' then
        local start_time = input.start_time or os.date('%Y-%m-%dT00:00:00')
        local end_time = input.end_time or os.date('%Y-%m-%dT23:59:59')

        get_window_activity(start_time, end_time, function(result, error)
            if error then
                on_complete(false, error)
            else
                on_complete(result, nil)
            end
        end)
    elseif action == 'events' then
        local bucket_id = input.bucket_id
        if not bucket_id then
            on_complete(false, 'Missing required parameter: bucket_id')
            return
        end

        local query_params = {
            limit = input.limit or 10,
            start = input.start_time,
            ['end'] = input.end_time,
        }

        get_events(bucket_id, query_params, function(result, error)
            if error then
                on_complete(false, error)
            else
                local output = string.format('📋 Events from %s:\n\n', bucket_id)

                if result and #result > 0 then
                    for i, event in ipairs(result) do
                        output = output .. string.format('%d. %s\n', i, event.timestamp or 'No timestamp')
                        output = output .. string.format('   Duration: %.1f seconds\n', event.duration or 0)

                        if event.data then
                            for key, value in pairs(event.data) do
                                output = output .. string.format('   %s: %s\n', key, tostring(value))
                            end
                        end
                        output = output .. '\n'
                    end
                else
                    output = output .. 'No events found.'
                end

                on_complete(output, nil)
            end
        end)
    elseif action == 'query' then
        local query_string = input.query
        if not query_string then
            on_complete(false, 'Missing required parameter: query')
            return
        end

        local start_time = input.start_time or os.date('%Y-%m-%dT00:00:00')
        local end_time = input.end_time or os.date('%Y-%m-%dT23:59:59')

        -- Convert query string to array if it's a single string
        local query_array
        if type(query_string) == 'string' then
            -- Split by semicolon or newline for multi-line queries
            query_array = {}
            for line in query_string:gmatch('[^\r\n;]+') do
                local trimmed = line:match('^%s*(.-)%s*$')
                if trimmed ~= '' then
                    table.insert(query_array, trimmed)
                end
            end
        else
            query_array = query_string
        end

        local query_data = {
            query = { query_string }, -- Array with single complete query string
            timeperiods = { string.format('%s/%s', start_time, end_time) },
        }

        execute_query(query_data, function(result, error)
            if error then
                on_complete(false, error)
            else
                local output = '🔍 Query Results:\n\n'
                output = output .. vim.json.encode(result)
                on_complete(output, nil)
            end
        end)
    else
        on_complete(
            false,
            'Unknown action: '
                .. action
                .. '. Available actions: buckets, today, last_workday, window_activity, events, query'
        )
    end
end

return M
