local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

local json_decode_opts = { luanil = { object = true, array = true } }

M.name = 'datadog'

M.description =
    'Interact with Datadog API for logs, metrics, events, and monitoring data to help troubleshoot production issues'

M.param = {
    type = 'table',
    fields = {
        {
            name = 'action',
            description = 'Action to perform: "search_logs", "query_metrics", "search_events", "get_monitors", "get_dashboard", "get_service_summary"',
            type = 'string',
        },
        {
            name = 'query',
            description = 'Search query string (for logs/events) or metric name (for metrics)',
            type = 'string',
            optional = true,
        },
        {
            name = 'from_time',
            description = 'Start time in ISO format (e.g., "2024-01-01T00:00:00Z") or relative (e.g., "1h", "24h", "7d")',
            type = 'string',
            optional = true,
        },
        {
            name = 'to_time',
            description = 'End time in ISO format or "now" (defaults to now)',
            type = 'string',
            optional = true,
        },
        {
            name = 'limit',
            description = 'Maximum number of results to return (default: 50, max: 1000)',
            type = 'number',
            optional = true,
        },
        {
            name = 'service',
            description = 'Service name to filter by',
            type = 'string',
            optional = true,
        },
        {
            name = 'environment',
            description = 'Environment to filter by (e.g., "production", "staging")',
            type = 'string',
            optional = true,
        },
        {
            name = 'dashboard_id',
            description = 'Dashboard ID (required for get_dashboard action)',
            type = 'string',
            optional = true,
        },
        {
            name = 'monitor_id',
            description = 'Monitor ID to get specific monitor details',
            type = 'string',
            optional = true,
        },
        {
            name = 'status',
            description = 'Filter monitors by status: "Alert", "Warn", "No Data", "OK"',
            type = 'string',
            optional = true,
        },
    },
}

M.returns = {
    {
        name = 'output',
        description = 'Datadog API response or formatted output',
        type = 'string',
    },
    {
        name = 'error',
        description = 'Error message if the operation failed',
        type = 'string',
        optional = true,
    },
}

-- Helper function to get Datadog configuration
local function get_datadog_config()
    local api_key = os.getenv('DATADOG_API_KEY') or os.getenv('DD_API_KEY')
    local app_key = os.getenv('DATADOG_APP_KEY') or os.getenv('DD_APP_KEY')
    local site = os.getenv('DATADOG_SITE') or os.getenv('DD_SITE') or 'datadoghq.com'

    if not api_key then
        return nil, 'DATADOG_API_KEY or DD_API_KEY environment variable not set'
    end

    if not app_key then
        return nil, 'DATADOG_APP_KEY or DD_APP_KEY environment variable not set'
    end

    return {
        api_key = api_key,
        app_key = app_key,
        site = site,
        base_url = 'https://api.' .. site,
    },
        nil
end

-- Helper function to convert relative time to timestamp
local function parse_time(time_str)
    if not time_str or time_str == 'now' then
        return os.time()
    end

    -- Check if it's already a timestamp
    local timestamp = tonumber(time_str)
    if timestamp then
        return timestamp
    end

    -- Check if it's ISO format
    if time_str:match('%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ?') then
        -- Convert ISO to timestamp (simplified)
        local year, month, day, hour, min, sec = time_str:match('(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)')
        if year then
            return os.time({
                year = tonumber(year),
                month = tonumber(month),
                day = tonumber(day),
                hour = tonumber(hour),
                min = tonumber(min),
                sec = tonumber(sec),
            })
        end
    end

    -- Handle relative time (e.g., "1h", "24h", "7d")
    local amount, unit = time_str:match('(%d+)([hdwmy])')
    if amount and unit then
        local multipliers = {
            h = 3600, -- hours
            d = 86400, -- days
            w = 604800, -- weeks
            m = 2592000, -- months (30 days)
            y = 31536000, -- years (365 days)
        }
        local multiplier = multipliers[unit]
        return os.time() - (tonumber(amount) * multiplier)
    end

    -- Default to current time if parsing fails
    return os.time()
end

-- Helper function to make HTTP requests to Datadog API
local function make_datadog_request(config, method, endpoint, params, body)
    local curl = require('plenary.curl')
    local url = config.base_url .. endpoint

    -- Prepare headers
    local headers = {
        ['DD-API-KEY'] = config.api_key,
        ['DD-APPLICATION-KEY'] = config.app_key,
        ['Content-Type'] = 'application/json',
    }

    -- Add query parameters
    if params then
        local query_params = {}
        for key, value in pairs(params) do
            if value ~= nil then
                table.insert(query_params, key .. '=' .. vim.uri_encode(tostring(value)))
            end
        end
        if #query_params > 0 then
            url = url .. '?' .. table.concat(query_params, '&')
        end
    end

    -- Prepare request options
    local opts = {
        url = url,
        method = method:lower(),
        headers = headers,
        timeout = 10000, -- 10 seconds timeout
    }

    -- Add body for POST requests
    if body then
        opts.body = vim.json.encode(body)
    end

    -- Execute the request
    local response = curl.request(opts)

    if not response then
        return nil, 'HTTP request failed: No response received'
    end

    if response.status >= 400 then
        local error_msg = 'HTTP request failed with status ' .. response.status
        if response.body then
            local success, parsed = pcall(vim.json.decode, response.body, json_decode_opts)
            if success and parsed.errors then
                error_msg = error_msg .. ': ' .. table.concat(parsed.errors, ', ')
            else
                error_msg = error_msg .. ': ' .. response.body
            end
        end
        return nil, error_msg
    end

    -- Parse JSON response
    if response.body and response.body ~= '' then
        local success, parsed = pcall(vim.json.decode, response.body, json_decode_opts)
        if success then
            return parsed, nil
        else
            return response.body, nil
        end
    else
        return {}, nil
    end
end

-- Helper function to format log entries
local function format_logs(logs_data)
    if not logs_data or not logs_data.data then
        return 'No logs found'
    end

    local output = {}
    table.insert(output, string.format('Found %d logs:', #logs_data.data))
    table.insert(output, '')

    for i, log in ipairs(logs_data.data) do
        if i > 50 then -- Limit output
            table.insert(output, '... (truncated)')
            break
        end

        local timestamp = log.attributes and log.attributes.timestamp or 'N/A'
        local message = log.attributes and log.attributes.message or 'N/A'
        local service = log.attributes and log.attributes.service or 'N/A'
        local status = log.attributes and log.attributes.status or 'N/A'

        table.insert(output, string.format('[%s] %s | %s | %s', timestamp, service, status, message))
    end

    return table.concat(output, '\n')
end

-- Helper function to format metrics data
local function format_metrics(metrics_data)
    if not metrics_data or not metrics_data.series then
        return 'No metrics data found'
    end

    local output = {}
    table.insert(output, string.format('Metrics query results (%d series):', #metrics_data.series))
    table.insert(output, '')

    for _, series in ipairs(metrics_data.series) do
        local metric_name = series.metric or 'Unknown'
        local unit = series.unit and series.unit[0] and series.unit[0].family or ''

        table.insert(output, string.format('Metric: %s %s', metric_name, unit))

        if series.pointlist and #series.pointlist > 0 then
            table.insert(output, string.format('  Data points: %d', #series.pointlist))
            -- Show last few data points
            local start_idx = math.max(1, #series.pointlist - 5)
            for i = start_idx, #series.pointlist do
                local point = series.pointlist[i]
                if point and #point >= 2 then
                    local timestamp = os.date('%Y-%m-%d %H:%M:%S', point[1] / 1000)
                    table.insert(output, string.format('    %s: %s', timestamp, tostring(point[2])))
                end
            end
        end
        table.insert(output, '')
    end

    return table.concat(output, '\n')
end

-- Helper function to format events
local function format_events(events_data)
    if not events_data or not events_data.data then
        return 'No events found'
    end

    local output = {}
    table.insert(output, string.format('Found %d events:', #events_data.data))
    table.insert(output, '')

    for i, event in ipairs(events_data.data) do
        if i > 20 then -- Limit output
            table.insert(output, '... (truncated)')
            break
        end

        local timestamp = event.attributes and event.attributes.timestamp or 'N/A'
        local title = event.attributes and event.attributes.title or 'N/A'
        local message = event.attributes and event.attributes.message or ''
        local source = event.attributes and event.attributes.source or 'N/A'

        table.insert(output, string.format('[%s] %s (%s)', timestamp, title, source))
        if message ~= '' then
            table.insert(output, string.format('  %s', message))
        end
        table.insert(output, '')
    end

    return table.concat(output, '\n')
end

-- Helper function to format monitors
local function format_monitors(monitors_data)
    if not monitors_data or #monitors_data == 0 then
        return 'No monitors found'
    end

    local output = {}
    table.insert(output, string.format('Found %d monitors:', #monitors_data))
    table.insert(output, '')

    for _, monitor in ipairs(monitors_data) do
        local name = monitor.name or 'Unnamed Monitor'
        local type = monitor.type or 'N/A'
        local status = monitor.overall_state or 'N/A'
        local message = monitor.message or ''

        table.insert(output, string.format('Monitor: %s (%s)', name, type))
        table.insert(output, string.format('  Status: %s', status))
        if message ~= '' then
            table.insert(output, string.format('  Message: %s', message))
        end
        table.insert(output, '')
    end

    return table.concat(output, '\n')
end

function M.func(input, opts)
    local on_complete = opts.on_complete
    local on_log = opts.on_log

    -- Get Datadog configuration
    local config, config_error = get_datadog_config()
    if config_error then
        on_complete(false, config_error)
        return
    end

    if on_log then
        on_log('Datadog Site: ' .. config.site)
        on_log('Action: ' .. input.action)
    end

    -- Parse time parameters
    local from_timestamp = parse_time(input.from_time or '24h') -- Default to last 24 hours
    local to_timestamp = parse_time(input.to_time or 'now')
    local limit = input.limit or 50

    if input.action == 'search_logs' then
        if not input.query then
            on_complete(false, 'query parameter is required for search_logs action')
            return
        end

        local params = {
            query = input.query,
            from = from_timestamp,
            to = to_timestamp,
            limit = limit,
        }

        -- Add filters if provided
        if input.service then
            params.query = params.query .. ' service:' .. input.service
        end
        if input.environment then
            params.query = params.query .. ' env:' .. input.environment
        end

        local response, err = make_datadog_request(config, 'POST', '/api/v2/logs/events/search', nil, {
            filter = {
                query = params.query,
                from = tostring(from_timestamp * 1000), -- Convert to milliseconds
                to = tostring(to_timestamp * 1000),
            },
            page = {
                limit = limit,
            },
        })

        if err then
            on_complete(false, 'Failed to search logs: ' .. err)
        else
            on_complete(format_logs(response), nil)
        end
    elseif input.action == 'query_metrics' then
        if not input.query then
            on_complete(false, 'query parameter is required for query_metrics action')
            return
        end

        local params = {
            query = input.query,
            from = from_timestamp,
            to = to_timestamp,
        }

        local response, err = make_datadog_request(config, 'GET', '/api/v1/query', params)

        if err then
            on_complete(false, 'Failed to query metrics: ' .. err)
        else
            on_complete(format_metrics(response), nil)
        end
    elseif input.action == 'search_events' then
        local params = {
            start = from_timestamp,
            ['end'] = to_timestamp,
        }

        if input.query then
            params.query = input.query
        end
        if input.service then
            params.sources = input.service
        end

        local response, err = make_datadog_request(config, 'POST', '/api/v2/events/search', nil, {
            filter = {
                query = params.query or '*',
                from = tostring(from_timestamp * 1000),
                to = tostring(to_timestamp * 1000),
            },
            page = {
                limit = limit,
            },
        })

        if err then
            on_complete(false, 'Failed to search events: ' .. err)
        else
            on_complete(format_events(response), nil)
        end
    elseif input.action == 'get_monitors' then
        local params = {}

        if input.monitor_id then
            -- Get specific monitor
            local response, err = make_datadog_request(config, 'GET', '/api/v1/monitor/' .. input.monitor_id)
            if err then
                on_complete(false, 'Failed to get monitor: ' .. err)
            else
                on_complete(format_monitors({ response }), nil)
            end
            return
        end

        -- Get all monitors with optional filters
        if input.status then
            params.group_states = input.status:lower()
        end

        local response, err = make_datadog_request(config, 'GET', '/api/v1/monitor', params)

        if err then
            on_complete(false, 'Failed to get monitors: ' .. err)
        else
            on_complete(format_monitors(response), nil)
        end
    elseif input.action == 'get_dashboard' then
        if not input.dashboard_id then
            on_complete(false, 'dashboard_id parameter is required for get_dashboard action')
            return
        end

        local response, err = make_datadog_request(config, 'GET', '/api/v1/dashboard/' .. input.dashboard_id)

        if err then
            on_complete(false, 'Failed to get dashboard: ' .. err)
        else
            local output = {}
            table.insert(output, 'Dashboard: ' .. (response.title or 'Untitled'))
            table.insert(output, 'Description: ' .. (response.description or 'No description'))
            table.insert(output, 'URL: https://app.' .. config.site .. '/dashboard/' .. input.dashboard_id)

            if response.widgets then
                table.insert(output, '')
                table.insert(output, string.format('Widgets (%d):', #response.widgets))
                for i, widget in ipairs(response.widgets) do
                    if i > 10 then
                        table.insert(output, '... (truncated)')
                        break
                    end
                    local title = widget.definition and widget.definition.title or 'Untitled Widget'
                    local type = widget.definition and widget.definition.type or 'unknown'
                    table.insert(output, string.format('  - %s (%s)', title, type))
                end
            end

            on_complete(table.concat(output, '\n'), nil)
        end
    elseif input.action == 'get_service_summary' then
        if not input.service then
            on_complete(false, 'service parameter is required for get_service_summary action')
            return
        end

        -- Get service overview by querying multiple endpoints
        local output = {}
        table.insert(output, 'Service Summary: ' .. input.service)
        table.insert(output, string.rep('=', 50))

        -- Try to get recent logs for the service
        local log_response, _ = make_datadog_request(config, 'POST', '/api/v2/logs/events/search', nil, {
            filter = {
                query = 'service:' .. input.service,
                from = tostring((os.time() - 3600) * 1000), -- Last hour
                to = tostring(os.time() * 1000),
            },
            page = { limit = 5 },
        })

        if log_response and log_response.data then
            table.insert(output, '')
            table.insert(output, string.format('Recent Logs (%d):', #log_response.data))
            for _, log in ipairs(log_response.data) do
                local timestamp = log.attributes and log.attributes.timestamp or 'N/A'
                local message = log.attributes and log.attributes.message or 'N/A'
                local status = log.attributes and log.attributes.status or 'N/A'
                table.insert(output, string.format('  [%s] %s: %s', timestamp, status, message))
            end
        end

        on_complete(table.concat(output, '\n'), nil)
    else
        on_complete(
            false,
            'Invalid action. Use: search_logs, query_metrics, search_events, get_monitors, get_dashboard, or get_service_summary'
        )
    end
end

return M
