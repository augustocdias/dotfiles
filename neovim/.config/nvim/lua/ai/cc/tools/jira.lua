local handlers = require('ai.cc.utils')

local json_decode_opts = { luanil = { object = true, array = true } }

-- Helper function to get Jira configuration
local function get_jira_config()
    local jira_url = os.getenv('JIRA_URL')
    local auth_token = os.getenv('JIRA_TOKEN')

    if not jira_url then
        return nil, 'JIRA_URL not provided and not set in environment variables'
    end

    if not auth_token then
        return nil, 'JIRA_TOKEN not provided and not set in environment variables'
    end

    -- Clean up URL
    jira_url = jira_url:gsub('/$', '')

    return {
        url = jira_url,
        token = auth_token,
    }, nil
end

-- Helper function to make HTTP requests to Jira API
local function make_jira_request(config, method, endpoint, body)
    local curl = require('plenary.curl')
    local url = config.url .. '/rest/api/3' .. endpoint

    -- Prepare headers
    local headers = {
        ['Content-Type'] = 'application/json',
    }

    local auth = nil
    -- Add authentication header
    if config.token:match(':') then
        -- If token contains colon, it's likely email:token format (Basic auth)
        auth = config.token
    else
        -- Assume it's already a bearer token or API token
        headers['Authorization'] = 'Bearer ' .. config.token
    end

    -- Prepare request options
    local opts = {
        url = url,
        method = method:lower(),
        headers = headers,
        timeout = 3000, -- 3 seconds timeout
        auth = auth,
    }

    -- Add body for POST/PUT requests
    if body then
        opts.body = body
    end

    -- Execute the request
    local response = curl.request(opts)

    if not response then
        return nil, 'HTTP request failed: No response received'
    end

    if response.status >= 400 then
        return nil,
            'HTTP request failed with status ' .. response.status .. ': ' .. (response.body or 'No error message')
    end

    -- Try to parse JSON response
    if response.body and response.body ~= '' then
        local success, parsed = pcall(vim.json.decode, response.body, json_decode_opts)
        if success then
            return parsed, nil
        else
            -- Return raw response if JSON parsing fails
            return response.body, nil
        end
    else
        return '', nil -- Empty response is valid for some operations
    end
end

-- Helper function to format issue output
local function format_issue_output(issue)
    local output = {}
    table.insert(output, 'Issue: ' .. (issue.key or 'N/A'))
    table.insert(output, 'Summary: ' .. (issue.fields and issue.fields.summary or 'N/A'))
    table.insert(output, 'Status: ' .. (issue.fields and issue.fields.status and issue.fields.status.name or 'N/A'))
    table.insert(
        output,
        'Assignee: ' .. (issue.fields and issue.fields.assignee and issue.fields.assignee.displayName or 'Unassigned')
    )
    table.insert(
        output,
        'Reporter: ' .. (issue.fields and issue.fields.reporter and issue.fields.reporter.displayName or 'N/A')
    )
    table.insert(
        output,
        'Priority: ' .. (issue.fields and issue.fields.priority and issue.fields.priority.name or 'N/A')
    )

    if issue.fields and issue.fields.description then
        table.insert(
            output,
            'Description: '
                .. (
                    issue.fields.description.content
                        and issue.fields.description.content[1]
                        and issue.fields.description.content[1].content
                        and issue.fields.description.content[1].content[1]
                        and issue.fields.description.content[1].content[1].text
                    or 'N/A'
                )
        )
    end

    return table.concat(output, '\n')
end

-- Helper function to format transitions output
local function format_transitions_output(transitions)
    local output = {}
    table.insert(output, 'Available Transitions:')

    for _, transition in ipairs(transitions.transitions or {}) do
        table.insert(
            output,
            string.format(
                '  - ID: %s, Name: %s -> %s',
                transition.id,
                transition.name,
                transition.to and transition.to.name or 'N/A'
            )
        )
    end

    return table.concat(output, '\n')
end

return handlers.create_tool({
    name = 'jira',
    description = 'Interact with Atlassian Jira API for ticket management, transitions, and comments',
    properties = {
        action = {
            type = 'string',
            description = 'Action to perform: "get_issue", "get_transitions", "transition", "add_comment", "get_comments", or "search"',
        },
        issue_key = {
            type = 'string',
            description = 'Jira issue key (e.g., "PROJ-123")',
        },
        transition_id = {
            type = 'string',
            description = 'ID of the transition to perform (required for "transition" action)',
        },
        comment_text = {
            type = 'string',
            description = 'Comment text to add (required for "add_comment" action)',
        },
        jql_query = {
            type = 'string',
            description = 'JQL query for searching issues (required for "search" action)',
        },
        fields = {
            type = 'string',
            description = 'Additional fields to update during transition (JSON object as string)',
        },
    },
    required = { 'action' },
    ui_log = function(tool)
        return ' Jira: ' .. tool.args.action
    end,
    prompt = function(self)
        if self.args.action == 'transition' then
            local config, config_error = get_jira_config()
            if config_error then
                return '', config_error
            end
            local transitions_response, transitions_err =
                make_jira_request(config, 'GET', '/issue/' .. self.args.issue_key .. '/transitions', nil)
            local target_status_name = self.args.transition_id -- fallback to ID if we can't find name
            if not transitions_err and transitions_response and transitions_response.transitions then
                for _, transition in ipairs(transitions_response.transitions) do
                    if transition.id == self.args.transition_id then
                        target_status_name = transition.to and transition.to.name or transition.name
                        break
                    end
                end
            end
            return 'Are you sure you want to transition issue '
                .. self.args.issue_key
                .. ' to "'
                .. target_status_name
                .. '"?'
        elseif self.args.action == 'add_comment' then
            return 'Are you sure you want to add the following comment to the issue '
                .. self.args.issue_key
                .. '? '
                .. self.args.comment_text
        end
        return 'This action ' .. self.args.action .. ' should not ask for permition. Check tool implementation.'
    end,
    prompt_condition = function(self)
        return vim.tbl_contains({ 'transition', 'add_comment' }, self.args.action)
    end,
    func = function(_, schema_params, _, output_handler)
        local action = schema_params.action

        -- Get Jira configuration
        local config, config_error = get_jira_config()
        if config_error then
            output_handler({ status = 'error', data = config_error })
        end

        if action == 'get_issue' then
            if not schema_params.issue_key then
                output_handler({ status = 'error', data = 'issue_key is required for get_issue action' })
            end

            local response, err = make_jira_request(config, 'GET', '/issue/' .. schema_params.issue_key, nil)
            if err then
                output_handler({ status = 'error', data = 'Failed to get issue: ' .. err })
            end

            if response.errorMessages then
                output_handler({
                    status = 'error',
                    data = 'Jira API error: ' .. table.concat(response.errorMessages, ', '),
                })
            end

            output_handler({ status = 'success', data = format_issue_output(response) })
        elseif action == 'get_transitions' then
            if not schema_params.issue_key then
                output_handler({
                    status = 'error',
                    data = 'issue_key is required for get_transitions action',
                })
            end

            local response, err =
                make_jira_request(config, 'GET', '/issue/' .. schema_params.issue_key .. '/transitions', nil)
            if err then
                output_handler({ status = 'error', data = 'Failed to get transitions: ' .. err })
            end

            if response.errorMessages then
                output_handler({
                    status = 'error',
                    data = 'Jira API error: ' .. table.concat(response.errorMessages, ', '),
                })
            end

            output_handler({ status = 'success', data = format_transitions_output(response) })
        elseif action == 'transition' then
            if not schema_params.issue_key then
                output_handler({ status = 'error', data = 'issue_key is required for transition action' })
            end
            if not schema_params.transition_id then
                output_handler({
                    status = 'error',
                    data = 'transition_id is required for transition action',
                })
            end

            -- Build transition request body
            local transition_body = {
                transition = {
                    id = schema_params.transition_id,
                },
            }

            -- Add additional fields if provided
            if schema_params.fields then
                local success, fields = pcall(vim.json.decode, schema_params.fields, json_decode_opts)
                if success then
                    transition_body.fields = fields
                else
                    output_handler({
                        status = 'error',
                        data = 'Invalid JSON in fields parameter: ' .. schema_params.fields,
                    })
                end
            end

            -- Get transitions to find the target status name
            local transitions_response, transitions_err =
                make_jira_request(config, 'GET', '/issue/' .. schema_params.issue_key .. '/transitions', nil)

            local target_status_name = schema_params.transition_id
            if not transitions_err and transitions_response and transitions_response.transitions then
                for _, transition in ipairs(transitions_response.transitions) do
                    if transition.id == schema_params.transition_id then
                        target_status_name = transition.to and transition.to.name or transition.name
                        break
                    end
                end
            end

            local body_json = vim.json.encode(transition_body)
            local response, err =
                make_jira_request(config, 'POST', '/issue/' .. schema_params.issue_key .. '/transitions', body_json)

            if err then
                output_handler({ status = 'error', data = 'Failed to transition issue: ' .. err })
            end

            if response and response.errorMessages then
                output_handler({
                    status = 'error',
                    data = 'Jira API error: ' .. table.concat(response.errorMessages, ', '),
                })
            end

            output_handler({
                status = 'success',
                data = 'Successfully transitioned issue '
                    .. schema_params.issue_key
                    .. ' to "'
                    .. target_status_name
                    .. '"',
            })
        elseif action == 'add_comment' then
            if not schema_params.issue_key then
                output_handler({ status = 'error', data = 'issue_key is required for add_comment action' })
            end
            if not schema_params.comment_text then
                output_handler({
                    status = 'error',
                    data = 'comment_text is required for add_comment action',
                })
            end

            -- Build comment request body
            local comment_body = {
                body = schema_params.comment_text,
            }

            local body_json = vim.json.encode(comment_body)
            local response, err =
                make_jira_request(config, 'POST', '/issue/' .. schema_params.issue_key .. '/comment', body_json)

            if err then
                output_handler({ status = 'error', data = 'Failed to add comment: ' .. err })
            end

            if response and response.errorMessages then
                output_handler({
                    status = 'error',
                    data = 'Jira API error: ' .. table.concat(response.errorMessages, ', '),
                })
            end

            local output = 'Successfully added comment to issue ' .. schema_params.issue_key
            if response and response.id then
                output = output .. ' (Comment ID: ' .. response.id .. ')'
            end

            output_handler({ status = 'success', data = output })
        elseif action == 'get_comments' then
            if not schema_params.issue_key then
                output_handler({
                    status = 'error',
                    data = 'issue_key is required for get_comments action',
                })
            end

            local response, err =
                make_jira_request(config, 'GET', '/issue/' .. schema_params.issue_key .. '/comment', nil)
            if err then
                output_handler({ status = 'error', data = 'Failed to get comments: ' .. err })
            end

            if response.errorMessages then
                output_handler({
                    status = 'error',
                    data = 'Jira API error: ' .. table.concat(response.errorMessages, ', '),
                })
            end

            local comments_output = {}
            table.insert(comments_output, 'Comments for issue ' .. schema_params.issue_key .. ':')

            for _, comment in ipairs(response.comments or {}) do
                local comment_text = 'N/A'
                if comment.body and comment.body.content then
                    -- Extract text from ADF format
                    for _, content in ipairs(comment.body.content) do
                        if content.content then
                            for _, inner_content in ipairs(content.content) do
                                if inner_content.text then
                                    comment_text = inner_content.text
                                    break
                                end
                            end
                        end
                    end
                end

                table.insert(
                    comments_output,
                    string.format(
                        '  - %s (%s): %s',
                        comment.author and comment.author.displayName or 'Unknown',
                        comment.created or 'N/A',
                        comment_text
                    )
                )
            end

            output_handler({ status = 'success', data = table.concat(comments_output, '\n') })
        elseif action == 'search' then
            if not schema_params.jql_query then
                output_handler({ status = 'error', data = 'jql_query is required for search action' })
            end

            local search_body = {
                jql = schema_params.jql_query,
                maxResults = 50,
                fields = { 'summary', 'status', 'assignee', 'reporter', 'priority' },
            }

            local body_json = vim.json.encode(search_body)
            local response, err = make_jira_request(config, 'POST', '/search/jql', body_json)

            if err then
                output_handler({ status = 'error', data = 'Failed to search issues: ' .. err })
            end

            if response.errorMessages then
                output_handler({
                    status = 'error',
                    data = 'Jira API error: ' .. table.concat(response.errorMessages, ', '),
                })
            end

            local search_output = {}
            table.insert(search_output, string.format('Search results (%d issues found):', response.total or 0))

            for _, issue in ipairs(response.issues or {}) do
                table.insert(
                    search_output,
                    string.format(
                        '  - %s: %s [%s]',
                        issue.key,
                        issue.fields and issue.fields.summary or 'N/A',
                        issue.fields and issue.fields.status and issue.fields.status.name or 'N/A'
                    )
                )
            end

            output_handler({ status = 'success', data = table.concat(search_output, '\n') })
        else
            output_handler({
                status = 'error',
                data = 'Invalid action. Use: get_issue, get_transitions, transition, add_comment, get_comments, or search',
            })
        end
    end,
    system_prompt = [[Interact with Atlassian Jira API for comprehensive ticket and project management. This tool provides access to issues, transitions, comments, and search functionality.

**Environment Variables Required**:
- `JIRA_URL`: Your Jira instance URL (e.g., https://yourcompany.atlassian.net)
- `JIRA_TOKEN`: API token for authentication (email:token format or bearer token)

**Available Actions**:

1. **get_issue**: Retrieve detailed information about a specific issue
   - Requires: `issue_key` (e.g., "PROJ-123")
   - Returns: Title, summary, status, assignee, reporter, priority, and description

2. **get_transitions**: Get available workflow transitions for an issue
   - Requires: `issue_key`
   - Returns: List of possible transitions with IDs and target statuses
   - Use this before transitioning to know what transition IDs are valid

3. **transition**: Move an issue to a different status (e.g., "In Progress" → "Done")
   - Requires: `issue_key`, `transition_id`
   - Optional: `fields` (JSON string) for additional field updates
   - **Requires user approval**
   - Use get_transitions first to find the correct transition_id

4. **add_comment**: Add a comment to an issue
   - Requires: `issue_key`, `comment_text`
   - **Requires user approval**
   - Comments should be either formatted in Atlassian Document Format (https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/) or plain text (don't add markdown markups there)

5. **get_comments**: Retrieve all comments on an issue
   - Requires: `issue_key`
   - Returns: Comments with author, timestamp, and text content

6. **search**: Search for issues using JQL (Jira Query Language)
   - Requires: `jql_query` (e.g., "project = PROJ AND status = Open")
   - Returns: Up to 50 matching issues with key, summary, and status
   - Useful for finding issues by various criteria

**Security**: Write operations (transition, add_comment) require user approval. Read operations execute immediately.]],
})
