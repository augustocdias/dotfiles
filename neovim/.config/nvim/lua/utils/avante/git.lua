local wrap_schedule = require('utils').wrap_schedule
local Helpers = require('avante.llm_tools.helpers')
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

-- Whitelist of read-only git commands that don't require confirmation
local READ_ONLY_COMMANDS = {
    'status',
    'log',
    'show',
    'diff',
    'blame',
    'reflog',
    'describe',
    'rev-parse',
    'symbolic-ref',
    'ls-files',
    'ls-remote',
    'ls-tree',
    'cat-file',
    'rev-list',
    'name-rev',
    'merge-base',
    'count-objects',
    'fsck',
    'verify-commit',
    'verify-tag',
    'check-ignore',
    'check-attr',
    'check-mailmap',
    'whatchanged',
    'shortlog',
    'archive',
    'bundle', -- when used for verification
    'help',
    'version',
    '--version',
}

-- Commands that are read-only when used with specific flags
local CONDITIONAL_READ_ONLY = {
    branch = { '--list', '-l', '--show-current', '--contains', '--merged', '--no-merged' },
    remote = { '--verbose', '-v', 'show', 'get-url' },
    tag = { '--list', '-l', '--contains', '--merged', '--no-merged', '--points-at' },
    config = { '--get', '--get-all', '--get-regexp', '--list', '-l' },
    stash = { 'list', 'show' },
    worktree = { 'list' },
    bundle = { 'verify', 'list-heads' },
}

-- Helper function to check if a git command is read-only
local function is_read_only_command(command, args)
    -- Check direct read-only commands
    if vim.tbl_contains(READ_ONLY_COMMANDS, command) then
        return true
    end

    -- Check conditional read-only commands
    if CONDITIONAL_READ_ONLY[command] and args then
        local arg_list = vim.split(args, '%s+')
        for _, read_only_flag in ipairs(CONDITIONAL_READ_ONLY[command]) do
            if vim.tbl_contains(arg_list, read_only_flag) then
                return true
            end
        end
    end

    return false
end

function M.git_tool()
    return {
        name = 'git',
        description = 'Execute git commands with automatic confirmation for write operations',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'command',
                    description = 'Git command to execute (e.g., status, log, add, commit, push). Try to limit commit msgs to 80 characters',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'args',
                    description = 'Additional arguments for the git command',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Output from the git command',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the command failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not params.command then
                on_complete(false, 'command parameter is required')
                return
            end

            -- Build the command
            local cmd_parts = { 'git', params.command }
            if params.args then
                local args_list = vim.split(params.args, '%s+')
                vim.list_extend(cmd_parts, args_list)
            end

            local cmd_string = table.concat(cmd_parts, ' ')
            local description = 'Git ' .. params.command
            local requires_confirmation = not is_read_only_command(params.command, params.args)

            if on_log then
                on_log(' Running command: ' .. cmd_string)
            end

            local function run_git_command()
                local full_command = 'git ' .. params.command
                if params.args then
                    full_command = full_command .. ' ' .. params.args
                end

                vim.system({ 'sh', '-c', full_command }, function(result)
                    if result.code ~= 0 then
                        wrap_schedule(
                            on_complete,
                            false,
                            'Git command failed with exit code '
                                .. result.code
                                .. ': '
                                .. (result.stderr or 'unknown error')
                        )
                        return
                    end

                    wrap_schedule(on_complete, result.stdout or '')
                end)
            end

            -- Only require confirmation for write operations
            if requires_confirmation then
                Helpers.confirm('Are you sure you want to run ' .. cmd_string .. '?', function(ok, reason)
                    if not ok then
                        on_complete(false, 'User declined ' .. description .. ': ' .. (reason or 'unknown'))
                        return
                    end
                    run_git_command()
                end)
            else
                run_git_command()
            end
        end,
    }
end

return M
