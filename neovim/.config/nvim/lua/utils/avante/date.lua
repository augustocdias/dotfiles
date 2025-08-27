local wrap_schedule = require('utils').wrap_schedule
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

M.name = 'date'
M.description = 'Providate date calculations based on today'
M.param = {
    type = 'table',
    fields = {
        {
            name = 'format',
            description = 'Date format to get. Check the docs for unix `date` utility. Example: %A, %d. %B %Y at %H:%M:%S to get for example Tuesday, 26. August 2025 at 20:36:19',
            type = 'string',
            optional = 'true',
        },
        {
            name = 'operations',
            description = 'Value to add/substract from the date. It follows the format of the unix utility `date`',
            type = 'array',
            optional = true,
            items = {
                name = 'op',
                description = [[
                    Each operation to execute. Follows the format of [+|-][NUMBER][METRIC]. Where:
                    + to means add and - means minus
                    the NUMBER is the value to be added or subtracted
                    and METRIC means what field should be operated on (month, day, hour, etc). Possible values are: y|m|w|d|H|M|S
                    y: year
                    m: month
                    w: week
                    d: day
                    H: hour
                    M: minute
                    S: second
                ]],
                type = 'string',
            },
        },
    },
}
M.returns = {
    {
        name = 'output',
        description = 'The resulting date',
        type = 'string',
    },
    {
        name = 'error',
        description = 'Error message if the script failed',
        type = 'string',
        optional = true,
    },
}
M.func = function(params, opts)
    local on_log = opts.on_log
    local on_complete = opts.on_complete
    local operations = params.operations

    local cmd = { 'date' }
    for _, v in ipairs(operations or {}) do
        table.insert(cmd, '-v' .. v)
    end
    if params.format then
        table.insert(cmd, '+"' .. params.format .. '"')
    end
    on_log('📅 Getting date: ' .. table.concat(cmd, ' '))

    vim.system(cmd, function(result)
        if result.code ~= 0 then
            wrap_schedule(
                on_complete,
                false,
                'Date returned ' .. result.code .. ': ' .. (result.stderr or 'unknown error')
            )
            return
        end

        local stdout = result.stdout:gsub('\n$', '')
        wrap_schedule(on_complete, stdout or '')
    end)
end

return M
