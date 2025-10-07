local handlers = require('ai.cc.utils')

-- Helper function to build gh command based on tool and parameters
local function build_gh_command(tool_name, params)
    local cmd_parts = {}

    if tool_name == 'gh_issue' then
        table.insert(cmd_parts, 'issue')
        table.insert(cmd_parts, params.action)

        if params.action == 'create' then
            if params.title then
                table.insert(cmd_parts, '--title')
                table.insert(cmd_parts, params.title)
            end
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
            if params.number then
                table.insert(cmd_parts, params.number)
            end
        end
    elseif tool_name == 'gh_pr' then
        table.insert(cmd_parts, 'pr')
        table.insert(cmd_parts, params.action)

        if params.action == 'create' then
            if params.title then
                table.insert(cmd_parts, '--title')
                table.insert(cmd_parts, params.title)
            end
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
            if params.number then
                table.insert(cmd_parts, params.number)
            end
            if params.action == 'merge' and params.merge_method then
                table.insert(cmd_parts, '--' .. params.merge_method)
            end
        end
    elseif tool_name == 'gh_workflow' then
        table.insert(cmd_parts, 'workflow')
        table.insert(cmd_parts, params.action)

        if vim.tbl_contains({ 'view', 'run' }, params.action) then
            if params.workflow then
                table.insert(cmd_parts, params.workflow)
            end
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
        end
    elseif tool_name == 'gh_run' then
        table.insert(cmd_parts, 'run')
        table.insert(cmd_parts, params.action)

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
            if params.run_id then
                table.insert(cmd_parts, params.run_id)
            end
        end
    elseif tool_name == 'gh_search' then
        table.insert(cmd_parts, 'search')
        table.insert(cmd_parts, params.type)
        if params.query then
            table.insert(cmd_parts, params.query)
        end
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
    elseif tool_name == 'gh_status' then
        if params.type == 'activity' then
            table.insert(cmd_parts, 'status')
        elseif params.type == 'user' then
            table.insert(cmd_parts, 'api')
            table.insert(cmd_parts, 'user')
        elseif params.type == 'auth' then
            table.insert(cmd_parts, 'auth')
            table.insert(cmd_parts, 'status')
        end
    elseif tool_name == 'gh_repo' then
        table.insert(cmd_parts, 'repo')
        table.insert(cmd_parts, params.action)

        if params.action == 'create' then
            if params.name then
                table.insert(cmd_parts, params.name)
            end
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
            if params.repository then
                table.insert(cmd_parts, params.repository)
            end
            if params.action == 'clone' and params.clone_dir then
                table.insert(cmd_parts, params.clone_dir)
            end
        end
    end

    return cmd_parts
end

-- Helper function to check if action requires approval
local function requires_approval(tool_name, action)
    return (tool_name == 'gh_issue' and vim.tbl_contains({ 'create', 'close', 'reopen' }, action))
        or (tool_name == 'gh_pr' and vim.tbl_contains(
            { 'create', 'merge', 'close', 'reopen', 'ready', 'draft' },
            action
        ))
        or (tool_name == 'gh_workflow' and action == 'run')
        or (tool_name == 'gh_run' and vim.tbl_contains({ 'cancel', 'rerun' }, action))
        or (tool_name == 'gh_repo' and vim.tbl_contains({ 'create', 'clone', 'fork' }, action))
end

local function create_gh_tool(name, description, properties, required)
    return handlers.create_tool({
        name = name,
        func = function(_, schema_params, _, output_handler)
            local cmd_parts = build_gh_command(name, schema_params)
            local cmd = { 'gh' }
            vim.list_extend(cmd, cmd_parts)

            -- Execute the command
            vim.system(cmd, function(result)
                vim.schedule(function()
                    if result.code ~= 0 then
                        output_handler({
                            status = 'error',
                            data = 'Command failed with exit code '
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
        properties = properties,
        required = required or {},
        system_prompt = description,
        prompt_condition = function(self)
            return requires_approval(name, self.args.action)
        end,
        prompt = function(self)
            return 'Are you sure you want to run: ' .. (self._cmd_string or 'gh command') .. '?'
        end,
    })
end

-- Export all tools
return {
    gh_issue = create_gh_tool('gh_issue', 'GitHub Issue operations (create, list, view, close, reopen)', {
        action = {
            type = 'string',
            description = 'Issue action: create, list, view, close, reopen',
        },
        number = {
            type = 'string',
            description = 'Issue number (required for view, close, reopen)',
        },
        title = {
            type = 'string',
            description = 'Issue title (required for create)',
        },
        body = {
            type = 'string',
            description = 'Issue description/body (for create)',
        },
        assignee = {
            type = 'string',
            description = 'Assignee username (for create/list filtering)',
        },
        label = {
            type = 'string',
            description = 'Label for issue (for create/list filtering)',
        },
        state = {
            type = 'string',
            description = 'Issue state for listing: open, closed, all (default: open)',
        },
        limit = {
            type = 'string',
            description = 'Maximum number of issues to list (default: 30)',
        },
    }, { 'action' }),

    gh_pr = create_gh_tool(
        'gh_pr',
        'GitHub Pull Request operations (create, list, view, merge, close, reopen, ready, draft)',
        {
            action = {
                type = 'string',
                description = 'PR action: create, list, view, merge, close, reopen, ready, draft',
            },
            number = {
                type = 'string',
                description = 'PR number (required for view, merge, close, reopen, ready, draft)',
            },
            title = {
                type = 'string',
                description = 'PR title (required for create)',
            },
            body = {
                type = 'string',
                description = 'PR description/body (for create)',
            },
            base = {
                type = 'string',
                description = 'Base branch (for create, defaults to main)',
            },
            head = {
                type = 'string',
                description = 'Head branch (for create, defaults to current branch)',
            },
            draft = {
                type = 'boolean',
                description = 'Create as draft PR (for create)',
            },
            assignee = {
                type = 'string',
                description = 'Assignee username (for create/list filtering)',
            },
            label = {
                type = 'string',
                description = 'Label for PR (for create/list filtering)',
            },
            state = {
                type = 'string',
                description = 'PR state for listing: open, closed, merged, all (default: open)',
            },
            limit = {
                type = 'string',
                description = 'Maximum number of PRs to list (default: 30)',
            },
            merge_method = {
                type = 'string',
                description = 'Merge method: merge, squash, rebase (for merge action)',
            },
        },
        { 'action' }
    ),

    gh_workflow = create_gh_tool('gh_workflow', 'GitHub Actions workflow operations (list, view, run)', {
        action = {
            type = 'string',
            description = 'Workflow action: list, view, run',
        },
        workflow = {
            type = 'string',
            description = 'Workflow name or ID (required for view, run)',
        },
        ref = {
            type = 'string',
            description = 'Git reference for workflow run (branch/tag, for run)',
        },
        inputs = {
            type = 'string',
            description = 'Workflow inputs as JSON string (for run)',
        },
    }, { 'action' }),

    gh_run = create_gh_tool('gh_run', 'GitHub Actions run operations (list, view, cancel, rerun)', {
        action = {
            type = 'string',
            description = 'Run action: list, view, cancel, rerun',
        },
        run_id = {
            type = 'string',
            description = 'Run ID (required for view, cancel, rerun)',
        },
        workflow = {
            type = 'string',
            description = 'Workflow name/ID to filter runs (for list)',
        },
        status = {
            type = 'string',
            description = 'Run status filter: completed, in_progress, queued (for list)',
        },
        limit = {
            type = 'string',
            description = 'Maximum number of runs to list (default: 20)',
        },
    }, { 'action' }),

    gh_search = create_gh_tool('gh_search', 'GitHub search operations (repos, issues, prs, code)', {
        type = {
            type = 'string',
            description = 'Search type: repos, issues, prs, code',
        },
        query = {
            type = 'string',
            description = 'Search query string',
        },
        limit = {
            type = 'string',
            description = 'Maximum number of results (default: 30)',
        },
        sort = {
            type = 'string',
            description = 'Sort order: updated, created, stars, forks (varies by type)',
        },
        order = {
            type = 'string',
            description = 'Sort direction: asc, desc',
        },
    }, { 'type', 'query' }),

    gh_status = create_gh_tool('gh_status', 'GitHub repository and user status operations', {
        type = {
            type = 'string',
            description = 'Status type: auth (auth status), user (user info) or activity (assigned issues, prs, mentions, activity)',
            enum = { 'activity', 'user', 'auth' },
        },
    }, { 'type' }),

    gh_repo = create_gh_tool('gh_repo', 'GitHub Repository operations (view, list, create, clone, fork)', {
        action = {
            type = 'string',
            description = 'Repo action: view, list, create, clone, fork',
        },
        repository = {
            type = 'string',
            description = 'Repository name (owner/repo format, required for view, clone, fork)',
        },
        name = {
            type = 'string',
            description = 'Repository name (required for create)',
        },
        description = {
            type = 'string',
            description = 'Repository description (for create)',
        },
        private = {
            type = 'boolean',
            description = 'Create private repository (for create)',
        },
        clone_dir = {
            type = 'string',
            description = 'Directory to clone into (for clone)',
        },
        owner = {
            type = 'string',
            description = 'Repository owner for listing (for list)',
        },
        limit = {
            type = 'string',
            description = 'Maximum number of repositories to list (for list)',
        },
    }, { 'action' }),
}
