local Helpers = require('avante.llm_tools.helpers')
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

M.name = 'gh'

M.description = "Interact with GitHub's gh CLI tool for repository operations"

M.param = {
    type = 'table',
    fields = {
        {
            name = 'command',
            description = 'The gh command to execute (e.g., "pr create", "issue list", "repo view")',
            type = 'string',
        },
        {
            name = 'args',
            description = 'Additional arguments for the gh command',
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
    local cmd_string = 'gh ' .. input.command
    local cmd = { 'sh', '-c', 'gh' }
    if input.args then
        cmd_string = cmd_string .. ' ' .. input.args
        vim.list_extend(cmd, vim.split(input.args, '%s+'))
    end

    if on_log then
        on_log('Running command: ' .. cmd_string)
    end

    Helpers.confirm('Are you sure you want to run ' .. cmd_string .. '?', function(ok, reason)
        if not ok then
            on_complete(false, 'User declined, reason: ' .. (reason or 'unknown'))
            return
        end

        local result = vim.system(cmd):wait()
        local exit_code = result.code

        if exit_code ~= 0 then
            on_complete(false, 'Command failed with exit code ' .. exit_code .. ': ' .. output)
        end
        on_complete(result.stdout or true, nil)
    end)
end

return M
