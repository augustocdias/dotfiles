local wrap_schedule = require('utils').wrap_schedule
local Helpers = require('avante.llm_tools.helpers')
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

-- Helper function to execute gh commands
local function execute_gh_command(cmd_parts, description, requires_confirmation, on_log, on_complete)
    local cmd_string = 'gh ' .. table.concat(cmd_parts, ' ')

    if on_log then
        on_log(' Running command: ' .. cmd_string)
    end

    local function run_command()
        local cmd = { 'gh' }
        vim.list_extend(cmd, cmd_parts)

        vim.system(cmd, function(result)
            if result.code ~= 0 then
                wrap_schedule(
                    on_complete,
                    false,
                    'Command failed with exit code ' .. result.code .. ': ' .. (result.stderr or 'unknown error')
                )
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
            run_command()
        end)
    else
        run_command()
    end
end

-- GitHub Issue operations
function M.issue_tool()
    return {
        name = 'gh_issue',
        description = 'GitHub Issue operations (create, list, view, close, reopen)',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'action',
                    description = 'Issue action: create, list, view, close, reopen',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'number',
                    description = 'Issue number (required for view, close, reopen)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'title',
                    description = 'Issue title (required for create)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'body',
                    description = 'Issue description/body (for create)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'assignee',
                    description = 'Assignee username (for create/list filtering)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'label',
                    description = 'Label for issue (for create/list filtering)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'state',
                    description = 'Issue state for listing: open, closed, all (default: open)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'limit',
                    description = 'Maximum number of issues to list (default: 30)',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Issue operation result',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the operation failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not params.action then
                on_complete(false, 'action parameter is required')
                return
            end

            local cmd_parts = { 'issue', params.action }
            local description = 'Issue ' .. params.action
            local requires_confirmation = vim.tbl_contains({ 'create', 'close', 'reopen' }, params.action)

            -- Build command based on action
            if params.action == 'create' then
                if not params.title then
                    on_complete(false, 'title is required for issue creation')
                    return
                end

                table.insert(cmd_parts, '--title')
                table.insert(cmd_parts, params.title)

                if params.body then
                    table.insert(cmd_parts, '--body')
                    table.insert(cmd_parts, params.body)
                end

                if params.assignee then
                    table.insert(cmd_parts, '--assignee')
                    table.insert(cmd_parts, params.assignee)
                end

                if params.label then
                    table.insert(cmd_parts, '--label')
                    table.insert(cmd_parts, params.label)
                end
            elseif params.action == 'list' then
                if params.state then
                    table.insert(cmd_parts, '--state')
                    table.insert(cmd_parts, params.state)
                end

                if params.assignee then
                    table.insert(cmd_parts, '--assignee')
                    table.insert(cmd_parts, params.assignee)
                end

                if params.label then
                    table.insert(cmd_parts, '--label')
                    table.insert(cmd_parts, params.label)
                end

                if params.limit then
                    table.insert(cmd_parts, '--limit')
                    table.insert(cmd_parts, params.limit)
                end
            elseif vim.tbl_contains({ 'view', 'close', 'reopen' }, params.action) then
                if not params.number then
                    on_complete(false, 'number parameter is required for issue ' .. params.action)
                    return
                end
                table.insert(cmd_parts, params.number)
                description = description .. ' #' .. params.number
            else
                on_complete(
                    false,
                    'Invalid action: ' .. params.action .. '. Valid actions: create, list, view, close, reopen'
                )
                return
            end

            execute_gh_command(cmd_parts, description, requires_confirmation, on_log, on_complete)
        end,
    }
end

-- GitHub Pull Request operations
function M.pr_tool()
    return {
        name = 'gh_pr',
        description = 'GitHub Pull Request operations (create, list, view, merge, close, reopen, ready, draft)',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'action',
                    description = 'PR action: create, list, view, merge, close, reopen, ready, draft',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'number',
                    description = 'PR number (required for view, merge, close, reopen, ready, draft)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'title',
                    description = 'PR title (required for create)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'body',
                    description = 'PR description/body (for create)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'base',
                    description = 'Base branch (for create, defaults to main)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'head',
                    description = 'Head branch (for create, defaults to current branch)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'draft',
                    description = 'Create as draft PR (for create)',
                    type = 'boolean',
                    optional = true,
                },
                {
                    name = 'assignee',
                    description = 'Assignee username (for create/list filtering)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'label',
                    description = 'Label for PR (for create/list filtering)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'state',
                    description = 'PR state for listing: open, closed, merged, all (default: open)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'limit',
                    description = 'Maximum number of PRs to list (default: 30)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'merge_method',
                    description = 'Merge method: merge, squash, rebase (for merge action)',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'PR operation result',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the operation failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not params.action then
                on_complete(false, 'action parameter is required')
                return
            end

            local cmd_parts = { 'pr', params.action }
            local description = 'PR ' .. params.action
            local requires_confirmation =
                vim.tbl_contains({ 'create', 'merge', 'close', 'reopen', 'ready', 'draft' }, params.action)

            -- Build command based on action
            if params.action == 'create' then
                if not params.title then
                    on_complete(false, 'title is required for PR creation')
                    return
                end

                table.insert(cmd_parts, '--title')
                table.insert(cmd_parts, params.title)

                if params.body then
                    table.insert(cmd_parts, '--body')
                    table.insert(cmd_parts, params.body)
                end

                if params.base then
                    table.insert(cmd_parts, '--base')
                    table.insert(cmd_parts, params.base)
                end

                if params.head then
                    table.insert(cmd_parts, '--head')
                    table.insert(cmd_parts, params.head)
                end

                if params.draft then
                    table.insert(cmd_parts, '--draft')
                end

                if params.assignee then
                    table.insert(cmd_parts, '--assignee')
                    table.insert(cmd_parts, params.assignee)
                end

                if params.label then
                    table.insert(cmd_parts, '--label')
                    table.insert(cmd_parts, params.label)
                end
            elseif params.action == 'list' then
                if params.state then
                    table.insert(cmd_parts, '--state')
                    table.insert(cmd_parts, params.state)
                end

                if params.assignee then
                    table.insert(cmd_parts, '--assignee')
                    table.insert(cmd_parts, params.assignee)
                end

                if params.label then
                    table.insert(cmd_parts, '--label')
                    table.insert(cmd_parts, params.label)
                end

                if params.limit then
                    table.insert(cmd_parts, '--limit')
                    table.insert(cmd_parts, params.limit)
                end
            elseif vim.tbl_contains({ 'view', 'merge', 'close', 'reopen', 'ready', 'draft' }, params.action) then
                if not params.number then
                    on_complete(false, 'number parameter is required for PR ' .. params.action)
                    return
                end
                table.insert(cmd_parts, params.number)
                description = description .. ' #' .. params.number

                if params.action == 'merge' and params.merge_method then
                    table.insert(cmd_parts, '--' .. params.merge_method)
                end
            else
                on_complete(
                    false,
                    'Invalid action: '
                        .. params.action
                        .. '. Valid actions: create, list, view, merge, close, reopen, ready, draft'
                )
                return
            end

            execute_gh_command(cmd_parts, description, requires_confirmation, on_log, on_complete)
        end,
    }
end

-- GitHub Workflow operations
function M.workflow_tool()
    return {
        name = 'gh_workflow',
        description = 'GitHub Actions workflow operations (list, view, run)',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'action',
                    description = 'Workflow action: list, view, run',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'workflow',
                    description = 'Workflow name or ID (required for view, run)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'ref',
                    description = 'Git reference for workflow run (branch/tag, for run)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'inputs',
                    description = 'Workflow inputs as JSON string (for run)',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Workflow operation result',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the operation failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not params.action then
                on_complete(false, 'action parameter is required')
                return
            end

            local cmd_parts = { 'workflow', params.action }
            local description = 'Workflow ' .. params.action
            local requires_confirmation = (params.action == 'run')

            -- Build command based on action
            if vim.tbl_contains({ 'view', 'run' }, params.action) then
                if not params.workflow then
                    on_complete(false, 'workflow parameter is required for ' .. params.action)
                    return
                end

                table.insert(cmd_parts, params.workflow)
                description = description .. ' ' .. params.workflow

                if params.action == 'run' then
                    if params.ref then
                        table.insert(cmd_parts, '--ref')
                        table.insert(cmd_parts, params.ref)
                    end

                    if params.inputs then
                        table.insert(cmd_parts, '--json')
                        table.insert(cmd_parts, params.inputs)
                    end
                end
            elseif params.action ~= 'list' then
                on_complete(false, 'Invalid action: ' .. params.action .. '. Valid actions: list, view, run')
                return
            end

            execute_gh_command(cmd_parts, description, requires_confirmation, on_log, on_complete)
        end,
    }
end

-- GitHub Run operations
function M.run_tool()
    return {
        name = 'gh_run',
        description = 'GitHub Actions run operations (list, view, cancel, rerun)',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'action',
                    description = 'Run action: list, view, cancel, rerun',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'run_id',
                    description = 'Run ID (required for view, cancel, rerun)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'workflow',
                    description = 'Workflow name/ID to filter runs (for list)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'status',
                    description = 'Run status filter: completed, in_progress, queued (for list)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'limit',
                    description = 'Maximum number of runs to list (default: 20)',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Run operation result',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the operation failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not params.action then
                on_complete(false, 'action parameter is required')
                return
            end

            local cmd_parts = { 'run', params.action }
            local description = 'Run ' .. params.action
            local requires_confirmation = vim.tbl_contains({ 'cancel', 'rerun' }, params.action)

            -- Build command based on action
            if params.action == 'list' then
                if params.workflow then
                    table.insert(cmd_parts, '--workflow')
                    table.insert(cmd_parts, params.workflow)
                end

                if params.status then
                    table.insert(cmd_parts, '--status')
                    table.insert(cmd_parts, params.status)
                end

                if params.limit then
                    table.insert(cmd_parts, '--limit')
                    table.insert(cmd_parts, params.limit)
                end
            elseif vim.tbl_contains({ 'view', 'cancel', 'rerun' }, params.action) then
                if not params.run_id then
                    on_complete(false, 'run_id parameter is required for run ' .. params.action)
                    return
                end
                table.insert(cmd_parts, params.run_id)
                description = description .. ' ' .. params.run_id
            else
                on_complete(false, 'Invalid action: ' .. params.action .. '. Valid actions: list, view, cancel, rerun')
                return
            end

            execute_gh_command(cmd_parts, description, requires_confirmation, on_log, on_complete)
        end,
    }
end

-- GitHub Search operations
function M.search_tool()
    return {
        name = 'gh_search',
        description = 'GitHub search operations (repos, issues, prs, code)',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'type',
                    description = 'Search type: repos, issues, prs, code',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'query',
                    description = 'Search query string',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'limit',
                    description = 'Maximum number of results (default: 30)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'sort',
                    description = 'Sort order: updated, created, stars, forks (varies by type)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'order',
                    description = 'Sort direction: asc, desc',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Search results',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the search failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not params.type or not params.query then
                on_complete(false, 'type and query parameters are required')
                return
            end

            if not vim.tbl_contains({ 'repos', 'issues', 'prs', 'code' }, params.type) then
                on_complete(false, 'Invalid search type: ' .. params.type .. '. Valid types: repos, issues, prs, code')
                return
            end

            local cmd_parts = { 'search', params.type, params.query }
            local description = 'Search ' .. params.type .. ' for: ' .. params.query

            if params.limit then
                table.insert(cmd_parts, '--limit')
                table.insert(cmd_parts, params.limit)
            end

            if params.sort then
                table.insert(cmd_parts, '--sort')
                table.insert(cmd_parts, params.sort)
            end

            if params.order then
                table.insert(cmd_parts, '--order')
                table.insert(cmd_parts, params.order)
            end

            -- Search is always read-only, no confirmation needed
            execute_gh_command(cmd_parts, description, false, on_log, on_complete)
        end,
    }
end

-- GitHub Status operations
function M.status_tool()
    return {
        name = 'gh_status',
        description = 'GitHub repository and user status operations',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'type',
                    description = 'Status type: auth (auth status), user (user info) or activity (assigned issues, prs, mentions, activity)',
                    choices = { 'activity', 'user', 'auth' },
                    type = 'string',
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Status information',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the operation failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            local cmd_parts = {}
            local description = 'Get status'

            if params.type == 'activity' then
                cmd_parts = { 'status' }
                description = 'User activity'
            elseif params.type == 'user' then
                cmd_parts = { 'api', 'user' }
                description = 'User status'
            elseif params.type == 'auth' then
                -- Default to general status (auth status)
                cmd_parts = { 'auth', 'status' }
                description = 'Authentication status'
            else
                on_complete(false, 'Invalid param type')
                return
            end

            -- Status is always read-only, no confirmation needed
            execute_gh_command(cmd_parts, description, false, on_log, on_complete)
        end,
    }
end

-- GitHub Repository operations
function M.repo_tool()
    return {
        name = 'gh_repo',
        description = 'GitHub Repository operations (view, list, create, clone, fork)',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'action',
                    description = 'Repo action: view, list, create, clone, fork',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'repository',
                    description = 'Repository name (owner/repo format, required for view, clone, fork)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'name',
                    description = 'Repository name (required for create)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'description',
                    description = 'Repository description (for create)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'private',
                    description = 'Create private repository (for create)',
                    type = 'boolean',
                    optional = true,
                },
                {
                    name = 'clone_dir',
                    description = 'Directory to clone into (for clone)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'owner',
                    description = 'Repository owner for listing (for list)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'limit',
                    description = 'Maximum number of repositories to list (for list)',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Repository operation result',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the operation failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not params.action then
                on_complete(false, 'action parameter is required')
                return
            end

            local cmd_parts = { 'repo', params.action }
            local description = 'Repository ' .. params.action
            local requires_confirmation = vim.tbl_contains({ 'create', 'clone', 'fork' }, params.action)

            -- Build command based on action
            if params.action == 'create' then
                if not params.name then
                    on_complete(false, 'name is required for repository creation')
                    return
                end

                table.insert(cmd_parts, params.name)

                if params.description then
                    table.insert(cmd_parts, '--description')
                    table.insert(cmd_parts, params.description)
                end

                if params.private then
                    table.insert(cmd_parts, '--private')
                else
                    table.insert(cmd_parts, '--public')
                end
            elseif params.action == 'list' then
                if params.owner then
                    table.insert(cmd_parts, params.owner)
                end

                if params.limit then
                    table.insert(cmd_parts, '--limit')
                    table.insert(cmd_parts, params.limit)
                end
            elseif vim.tbl_contains({ 'view', 'clone', 'fork' }, params.action) then
                if not params.repository then
                    on_complete(false, 'repository parameter is required for ' .. params.action)
                    return
                end

                table.insert(cmd_parts, params.repository)
                description = description .. ' ' .. params.repository

                if params.action == 'clone' and params.clone_dir then
                    table.insert(cmd_parts, params.clone_dir)
                end
            else
                on_complete(
                    false,
                    'Invalid action: ' .. params.action .. '. Valid actions: view, list, create, clone, fork'
                )
                return
            end

            execute_gh_command(cmd_parts, description, requires_confirmation, on_log, on_complete)
        end,
    }
end

return M
