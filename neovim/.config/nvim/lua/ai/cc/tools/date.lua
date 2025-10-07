local handlers = require('ai.cc.utils')
return handlers.create_tool({
    name = 'date',
    description = 'Provide date calculations based on today',
    properties = {
        format = {
            type = 'string',
            description = 'Date format to get. Check the docs for unix `date` utility. Example: %A, %d. %B %Y at %H:%M:%S to get for example Tuesday, 26. August 2025 at 20:36:19',
        },
        operations = {
            type = 'array',
            description = 'Array of operations to add/subtract from the date',
            items = {
                type = 'string',
                description = [[Each operation to execute. Follows the format of [+|-][NUMBER][METRIC]. Where:
+ means add and - means minus
NUMBER is the value to be added or subtracted
METRIC means what field should be operated on (month, day, hour, etc). Possible values are: y|m|w|d|H|M|S
y: year
m: month
w: week
d: day
H: hour
M: minute
S: second]],
            },
        },
    },
    ui_log = '󰸗 Date',
    func = function(_, schema_params, _, output_handler)
        local operations = schema_params.operations or {}
        local format = schema_params.format

        local cmd = { 'date' }
        for _, v in ipairs(operations) do
            table.insert(cmd, '-v' .. v)
        end
        if format then
            table.insert(cmd, '+' .. format)
        end

        vim.system(cmd, function(result)
            vim.schedule(function()
                if result.code ~= 0 then
                    output_handler({
                        status = 'error',
                        data = 'Date command failed with exit code '
                            .. result.code
                            .. ': '
                            .. (result.stderr or 'unknown error'),
                    })
                else
                    local stdout = result.stdout:gsub('\n$', '')
                    output_handler({ status = 'success', data = stdout or '' })
                end
            end)
        end)
    end,
    system_prompt = [[Perform date calculations and formatting using the Unix `date` utility. This tool allows you to get the current date/time with custom formatting and perform relative date calculations.

**Formatting**: Use the `format` parameter with standard Unix date format specifiers (e.g., "%Y-%m-%d" for 2025-01-15, "%A, %d. %B %Y at %H:%M:%S" for "Tuesday, 26. August 2025 at 20:36:19").

**Operations**: Use the `operations` array to add or subtract time from the current date. Each operation follows the format `[+|-][NUMBER][METRIC]`:
- `+` to add, `-` to subtract
- NUMBER: the value to add/subtract
- METRIC: y (year), m (month), w (week), d (day), H (hour), M (minute), S (second)

Examples:
- Get tomorrow: operations: ["+1d"]
- Get date 3 months ago: operations: ["-3m"]
- Get date 2 weeks and 3 days from now: operations: ["+2w", "+3d"]

All operations are read-only and execute immediately. This is useful for scheduling, date calculations, and generating timestamps.]],
})
