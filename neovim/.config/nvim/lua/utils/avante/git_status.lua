local Helpers = require('avante.llm_tools.helpers')
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

M.name = 'git_status'

M.description = 'Execute git status'

M.param = {
    type = 'table',
    fields = {
        {
            name = 'args',
            description = 'Git status options (such as -s, -b, etc) and arguments (such as the pathspec)',
            type = 'string',
            optional = true,
        },
    },
    usage = {
        command = 'The gh command to execute',
        args = 'Additional command arguments (optional)',
    },
}

M.returns = {
    {
        name = 'output',
        description = 'Output from the gh command',
        type = 'string',
    },
    {
        name = 'error',
        description = 'Error message if the command failed',
        type = 'string',
        optional = true,
    },
}

function M.func(input, opts)
    local on_log = opts.on_log
    local on_complete = opts.on_complete
    local output = ''

    -- Build the command
    local cmd = { 'sh', '-c', 'git', 'status' }
    if input.args then
        vim.list_extend(cmd, vim.split(input.args, '%s+'))
    end

    local cmd_string = table.concat(cmd, ' ')
    if on_log then
        on_log('Running command: ' .. cmd_string)
    end

    vim.system(cmd, function(result)
        local exit_code = result.code

        if exit_code ~= 0 then
            on_complete(false, 'Command failed with exit code ' .. exit_code .. ': ' .. output)
        end
        on_complete(result.stdout or true, nil)
    end)
end

return M
