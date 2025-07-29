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
        {
            name = 'cwd',
            description = 'Working directory to run the command in',
            type = 'string',
            optional = true,
        },
    },
    usage = {
        command = 'The gh command to execute',
        args = 'Additional command arguments (optional)',
        cwd = 'Working directory (optional, defaults to current directory)',
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

    -- Check if gh CLI is available
    vim.fn.system('which gh')
    if vim.v.shell_error ~= 0 then
        return '', 'GitHub CLI (gh) is not installed or not in PATH'
    end

    -- Build the command
    local cmd = 'gh ' .. input.command
    if input.args then
        cmd = cmd .. ' ' .. input.args
    end

    -- Set working directory if provided
    local cwd = input.cwd or vim.fn.getcwd()
    local abs_path = Helpers.get_abs_path(cwd)

    if not Helpers.has_permission_to_access(abs_path) then
        return '', 'No permission to access path: ' .. abs_path
    end

    if on_log then
        on_log('Running command: ' .. cmd)
        on_log('Working directory: ' .. abs_path)
    end

    -- Execute the command
    local original_cwd = vim.fn.getcwd()
    vim.fn.chdir(abs_path)

    Helpers.confirm('Are you sure you want to run ' .. cmd .. '?', function(ok)
        if not ok then
            on_complete(false, 'User canceled')
            return
        end

        output = vim.fn.system(cmd)
        local exit_code = vim.v.shell_error

        vim.fn.chdir(original_cwd)

        if exit_code ~= 0 then
            return '', 'Command failed with exit code ' .. exit_code .. ': ' .. output
        end
        on_complete(true, nil)
    end)

    return output, nil
end

return M
