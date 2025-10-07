local handlers = require('ai.cc.utils')

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
    'bundle',
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

local function full_command_str(command, args)
    local result = 'git ' .. command
    if args ~= '' then
        result = result .. ' ' .. args
    end
    return result
end

return handlers.create_tool({
    name = 'git',
    description = 'Execute git commands with automatic confirmation for write operations',
    properties = {
        command = {
            type = 'string',
            description = 'Git command to execute (e.g., status, log, add, commit, push). Try to limit commit msgs to 80 characters',
        },
        args = {
            type = 'string',
            description = 'Additional arguments for the git command',
        },
    },
    required = { 'command' },
    prompt = function(self)
        local full_command = full_command_str(self.args.command, self.args.args)
        return 'Are you sure you want to run: ' .. full_command .. '?'
    end,
    prompt_condition = function(self)
        return not is_read_only_command(self.args.command, self.args.args)
    end,
    func = function(_, schema_params, _, output_handler)
        local command = schema_params.command
        local args = schema_params.args or ''

        if not command then
            return output_handler({ status = 'error', data = 'command parameter is required' })
        end

        if command:find('%s') then
            return output_handler({
                status = 'error',
                data = 'Command must not contain spaces. Use the "args" parameter for arguments.',
            })
        end

        -- Build the full command
        local full_command = full_command_str(command, args)

        -- Execute the command
        vim.system({ 'sh', '-c', full_command }, function(result)
            vim.schedule(function()
                if result.code ~= 0 then
                    output_handler({
                        status = 'error',
                        data = 'Git command failed with exit code '
                            .. result.code
                            .. ': '
                            .. (result.stderr or 'unknown error'),
                    })
                else
                    output_handler({ status = 'success', data = result.stdout or '' })
                end
            end)
        end)
    end,
})
