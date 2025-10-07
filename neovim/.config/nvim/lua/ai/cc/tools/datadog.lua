local handlers = require('ai.cc.utils')

local json_decode_opts = { luanil = { object = true, array = true } }

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

return handlers.create_tool({
    name = 'datadog',
    description = 'Interact with Datadog API for logs, metrics, events, and monitoring data to help troubleshoot production issues',
    properties = {
        action = {
            type = 'string',
            description = 'Action to perform: "search_logs", "query_metrics", "search_events", "get_monitors", "get_dashboard", "get_service_summary"',
        },
        query = {
            type = 'string',
            description = 'Search query string (for logs/events) or metric name (for metrics)',
        },
        from_time = {
            type = 'string',
            description = 'Start time in ISO format (e.g., "2024-01-01T00:00:00Z") or relative (e.g., "1h", "24h", "7d")',
        },
        to_time = {
            type = 'string',
            description = 'End time in ISO format or "now" (defaults to now)',
        },
        limit = {
            type = 'number',
            description = 'Maximum number of results to return (default: 50, max: 1000)',
        },
        service = {
            type = 'string',
            description = 'Service name to filter by',
        },
        environment = {
            type = 'string',
            description = 'Environment to filter by (e.g., "production", "staging")',
        },
        dashboard_id = {
            type = 'string',
            description = 'Dashboard ID (required for get_dashboard action)',
        },
        monitor_id = {
            type = 'string',
            description = 'Monitor ID to get specific monitor details',
        },
        status = {
            type = 'string',
            description = 'Filter monitors by status: "Alert", "Warn", "No Data", "OK"',
        },
    },
    required = { 'action' },
    ui_log = function(tool)
        return '󰩃 Datadog: ' .. tool.args.action
    end,
    func = function(_, schema_params, _, output_handler)
        -- Get Datadog configuration
        local config, config_error = get_datadog_config()
        if config_error then
            output_handler({ status = 'error', data = config_error })
            return
        end

        -- Parse time parameters
        local from_timestamp = parse_time(schema_params.from_time or '24h') -- Default to last 24 hours
        local to_timestamp = parse_time(schema_params.to_time or 'now')
        local limit = schema_params.limit or 50

        if schema_params.action == 'search_logs' then
            if not schema_params.query then
                output_handler({ status = 'error', data = 'query parameter is required for search_logs action' })
                return
            end

            local params = {
                query = schema_params.query,
                from = from_timestamp,
                to = to_timestamp,
                limit = limit,
            }

            -- Add filters if provided
            if schema_params.service then
                params.query = params.query .. ' service:' .. schema_params.service
            end
            if schema_params.environment then
                params.query = params.query .. ' env:' .. schema_params.environment
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
                output_handler({ status = 'error', data = 'Failed to search logs: ' .. err })
            else
                output_handler({ status = 'success', data = format_logs(response) })
            end
        elseif schema_params.action == 'query_metrics' then
            if not schema_params.query then
                output_handler({ status = 'error', data = 'query parameter is required for query_metrics action' })
                return
            end

            local params = {
                query = schema_params.query,
                from = from_timestamp,
                to = to_timestamp,
            }

            local response, err = make_datadog_request(config, 'GET', '/api/v1/query', params)

            if err then
                output_handler({ status = 'error', data = 'Failed to query metrics: ' .. err })
            else
                output_handler({ status = 'success', data = format_metrics(response) })
            end
        elseif schema_params.action == 'search_events' then
            local params = {
                start = from_timestamp,
                ['end'] = to_timestamp,
            }

            if schema_params.query then
                params.query = schema_params.query
            end
            if schema_params.service then
                params.sources = schema_params.service
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
                output_handler({ status = 'error', data = 'Failed to search events: ' .. err })
            else
                output_handler({ status = 'success', data = format_events(response) })
            end
        elseif schema_params.action == 'get_monitors' then
            local params = {}

            if schema_params.monitor_id then
                -- Get specific monitor
                local response, err =
                    make_datadog_request(config, 'GET', '/api/v1/monitor/' .. schema_params.monitor_id)
                if err then
                    output_handler({ status = 'error', data = 'Failed to get monitor: ' .. err })
                else
                    output_handler({ status = 'success', data = format_monitors({ response }) })
                end
                return
            end

            -- Get all monitors with optional filters
            if schema_params.status then
                params.group_states = schema_params.status:lower()
            end

            local response, err = make_datadog_request(config, 'GET', '/api/v1/monitor', params)

            if err then
                output_handler({ status = 'error', data = 'Failed to get monitors: ' .. err })
            else
                output_handler({ status = 'success', data = format_monitors(response) })
            end
        elseif schema_params.action == 'get_dashboard' then
            if not schema_params.dashboard_id then
                output_handler({
                    status = 'error',
                    data = 'dashboard_id parameter is required for get_dashboard action',
                })
                return
            end

            local response, err =
                make_datadog_request(config, 'GET', '/api/v1/dashboard/' .. schema_params.dashboard_id)

            if err then
                output_handler({ status = 'error', data = 'Failed to get dashboard: ' .. err })
            else
                local output = {}
                table.insert(output, 'Dashboard: ' .. (response.title or 'Untitled'))
                table.insert(output, 'Description: ' .. (response.description or 'No description'))
                table.insert(output, 'URL: https://app.' .. config.site .. '/dashboard/' .. schema_params.dashboard_id)

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

                output_handler({ status = 'success', data = table.concat(output, '\n') })
            end
        elseif schema_params.action == 'get_service_summary' then
            if not schema_params.service then
                output_handler({
                    status = 'error',
                    data = 'service parameter is required for get_service_summary action',
                })
                return
            end

            -- Get service overview by querying multiple endpoints
            local output = {}
            table.insert(output, 'Service Summary: ' .. schema_params.service)
            table.insert(output, string.rep('=', 50))

            -- Try to get recent logs for the service
            local log_response, _ = make_datadog_request(config, 'POST', '/api/v2/logs/events/search', nil, {
                filter = {
                    query = 'service:' .. schema_params.service,
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

            output_handler({ status = 'success', data = table.concat(output, '\n') })
        else
            output_handler({
                status = 'error',
                data = 'Invalid action. Use: search_logs, query_metrics, search_events, get_monitors, get_dashboard, or get_service_summary',
            })
        end
    end,

    system_prompt = [[Interact with Datadog API for monitoring, logs, metrics, and troubleshooting production issues. This tool provides comprehensive access to your Datadog monitoring data.

**Environment Variables Required**:
- `DATADOG_API_KEY` or `DD_API_KEY`: Your Datadog API key
- `DATADOG_APP_KEY` or `DD_APP_KEY`: Your Datadog application key
- `DATADOG_SITE` or `DD_SITE` (optional): Datadog site (default: datadoghq.com)

**Available Actions**:

1. **search_logs**: Search through application logs
   - Requires: `query` (search string)
   - Optional: `from_time`, `to_time`, `limit`, `service`, `environment`
   - Example queries: "error", "status:error service:api", "Exception"
   - Returns: Log entries with timestamps, messages, services, and status levels

2. **query_metrics**: Query metric data and time series
   - Requires: `query` (metric name/query)
   - Optional: `from_time`, `to_time`
   - Example: "avg:system.cpu.user{*}", "sum:requests.count{env:prod}"
   - Returns: Metric values over time with data points

3. **search_events**: Search for Datadog events
   - Optional: `query`, `from_time`, `to_time`, `service`, `limit`
   - Returns: Events with titles, messages, sources, and timestamps
   - Useful for finding deployments, alerts, or custom events

4. **get_monitors**: Retrieve monitor status and configuration
   - Optional: `monitor_id` (for specific monitor), `status` (filter: Alert/Warn/OK)
   - Returns: Monitor names, types, current status, and alert messages
   - Use to check what's alerting or get monitor details

5. **get_dashboard**: Get dashboard configuration and widgets
   - Requires: `dashboard_id`
   - Returns: Dashboard title, description, URL, and widget information
   - Useful for understanding what metrics are being tracked

6. **get_service_summary**: Get a summary of service health and recent logs
   - Requires: `service` (service name)
   - Returns: Recent logs and service activity from the last hour
   - Quick way to check service health

**Time Parameters**:
- Supports ISO format: "2024-01-01T00:00:00Z"
- Supports relative time: "1h" (1 hour ago), "24h", "7d", "30d"
- Default: Last 24 hours

All operations are read-only and execute immediately. Use this tool for debugging production issues, checking metrics, and monitoring application health.]],
})
