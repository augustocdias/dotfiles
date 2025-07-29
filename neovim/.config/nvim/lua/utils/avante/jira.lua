local Base = require('avante.llm_tools.base')
local Helpers = require('avante.llm_tools.helpers')

local M = setmetatable({}, Base)

local json_decode_opts = { luanil = { object = true, array = true } }

M.name = 'jira'

M.description = 'Interact with Atlassian Jira API for ticket management, transitions, and comments'

M.param = {
    type = 'table',
    fields = {
        {
            name = 'action',
            description = 'Action to perform: "get_issue", "get_transitions", "transition", "add_comment", "get_comments", or "search"',
            type = 'string',
        },
        {
            name = 'issue_key',
            description = 'Jira issue key (e.g., "PROJ-123")',
            type = 'string',
            optional = true,
        },
        {
            name = 'transition_id',
            description = 'ID of the transition to perform (required for "transition" action)',
            type = 'string',
            optional = true,
        },
        {
            name = 'comment_text',
            description = 'Comment text to add (required for "add_comment" action)',
            type = 'string',
            optional = true,
        },
        {
            name = 'jql_query',
            description = 'JQL query for searching issues (required for "search" action)',
            type = 'string',
            optional = true,
        },
        {
            name = 'fields',
            description = 'Additional fields to update during transition (JSON object as string)',
            type = 'string',
            optional = true,
        },
    },
    usage = {
        action = 'Action to perform: get_issue/get_transitions/transition/add_comment/get_comments/search',
        issue_key = 'Jira issue key (optional for search)',
        transition_id = 'Transition ID (for transition action)',
        comment_text = 'Comment text (for add_comment action)',
        jql_query = 'JQL query (for search action)',
        fields = 'Additional fields as JSON string (optional)',
    },
}

M.returns = {
    {
        name = 'output',
        description = 'Jira API response or formatted output',
        type = 'string',
    },
    {
        name = 'error',
        description = 'Error message if the operation failed',
        type = 'string',
        optional = true,
    },
}

-- Helper function to get Jira configuration
local function get_jira_config(input)
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
    local url = config.url .. '/rest/api/latest' .. endpoint

    -- Build curl command
    local cmd = string.format('curl -s -X %s "%s"', method, url)

    -- Add authentication header
    if config.token:match(':') then
        -- If token contains colon, it's likely email:token format
        cmd = cmd .. ' --user "' .. config.token .. '"'
    else
        -- Assume it's already a bearer token or API token
        cmd = cmd .. ' -H "Authorization: Bearer ' .. config.token .. '"'
    end

    -- Add content type
    cmd = cmd .. ' -H "Content-Type: application/json"'

    -- Add body for POST/PUT requests
    if body then
        local escaped_body = body:gsub('"', '\\"')
        cmd = cmd .. ' -d "' .. escaped_body .. '"'
    end

    -- Execute the request
    local response = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error

    if exit_code ~= 0 then
        return nil, 'HTTP request failed: ' .. response
    end

    -- Try to parse JSON response
    local success, parsed = pcall(vim.json.decode, response, json_decode_opts)
    if success then
        return parsed, nil
    else
        -- Return raw response if JSON parsing fails
        return response, nil
    end
end

-- Helper function to format comment text as Atlassian Document Format (ADF)
local function format_comment_adf(text)
    return {
        type = 'doc',
        version = 1,
        content = {
            {
                type = 'paragraph',
                content = {
                    {
                        type = 'text',
                        text = text,
                    },
                },
            },
        },
    }
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

function M.func(input, opts)
    local on_complete = opts.on_complete
    local on_log = opts.on_log

    -- Get Jira configuration
    local config, config_error = get_jira_config(input)
    if config_error then
        return '', config_error
    end

    if on_log then
        on_log('Jira URL: ' .. config.url)
        on_log('Action: ' .. input.action)
    end

    local output = ''
    local error_msg = nil

    if input.action == 'get_issue' then
        if not input.issue_key then
            return '', 'issue_key is required for get_issue action'
        end

        local response, err = make_jira_request(config, 'GET', '/issue/' .. input.issue_key, nil)
        if err then
            error_msg = 'Failed to get issue: ' .. err
        else
            if response.errorMessages then
                error_msg = 'Jira API error: ' .. table.concat(response.errorMessages, ', ')
            else
                output = format_issue_output(response)
            end
        end
    elseif input.action == 'get_transitions' then
        if not input.issue_key then
            return '', 'issue_key is required for get_transitions action'
        end

        local response, err = make_jira_request(config, 'GET', '/issue/' .. input.issue_key .. '/transitions', nil)
        if err then
            error_msg = 'Failed to get transitions: ' .. err
        else
            if response.errorMessages then
                error_msg = 'Jira API error: ' .. table.concat(response.errorMessages, ', ')
            else
                output = format_transitions_output(response)
            end
        end
    elseif input.action == 'transition' then
        if not input.issue_key then
            return '', 'issue_key is required for transition action'
        end
        if not input.transition_id then
            return '', 'transition_id is required for transition action'
        end

        -- Build transition request body
        local transition_body = {
            transition = {
                id = input.transition_id,
            },
        }

        -- Add additional fields if provided
        if input.fields then
            local success, fields = pcall(vim.json.decode, input.fields, json_decode_opts)
            if success then
                transition_body.fields = fields
            else
                return '', 'Invalid JSON in fields parameter: ' .. input.fields
            end
        end

        local body_json = vim.json.encode(transition_body)
        Helpers.confirm(
            'Are you sure you want to transition issue ' .. input.issue_key .. ' to ' .. input.transition_id .. '?',
            function(ok)
                if not ok then
                    on_complete(false, 'User canceled')
                    return
                end
                local response, err =
                    make_jira_request(config, 'POST', '/issue/' .. input.issue_key .. '/transitions', body_json)

                if err then
                    error_msg = 'Failed to transition issue: ' .. err
                else
                    if response and response.errorMessages then
                        error_msg = 'Jira API error: ' .. table.concat(response.errorMessages, ', ')
                    else
                        output = 'Successfully transitioned issue '
                            .. input.issue_key
                            .. ' using transition ID '
                            .. input.transition_id
                    end
                end
                on_complete(true, nil)
            end
        )
    elseif input.action == 'add_comment' then
        if not input.issue_key then
            return '', 'issue_key is required for add_comment action'
        end
        if not input.comment_text then
            return '', 'comment_text is required for add_comment action'
        end

        -- Build comment request body
        local comment_body = {
            body = format_comment_adf(input.comment_text),
        }

        local body_json = vim.json.encode(comment_body)
        Helpers.confirm(
            'Are you sure you want to add the following comment to the issue '
                .. input.issue_key
                .. '? '
                .. input.comment_text,
            function(ok)
                if not ok then
                    on_complete(false, 'User canceled')
                    return
                end
                local response, err =
                    make_jira_request(config, 'POST', '/issue/' .. input.issue_key .. '/comment', body_json)

                if err then
                    error_msg = 'Failed to add comment: ' .. err
                else
                    if response and response.errorMessages then
                        error_msg = 'Jira API error: ' .. table.concat(response.errorMessages, ', ')
                    else
                        output = 'Successfully added comment to issue ' .. input.issue_key
                        if response and response.id then
                            output = output .. ' (Comment ID: ' .. response.id .. ')'
                        end
                    end
                end

                on_complete(true, nil)
            end
        )
    elseif input.action == 'get_comments' then
        if not input.issue_key then
            return '', 'issue_key is required for get_comments action'
        end

        local response, err = make_jira_request(config, 'GET', '/issue/' .. input.issue_key .. '/comment', nil)
        if err then
            error_msg = 'Failed to get comments: ' .. err
        else
            if response.errorMessages then
                error_msg = 'Jira API error: ' .. table.concat(response.errorMessages, ', ')
            else
                local comments_output = {}
                table.insert(comments_output, 'Comments for issue ' .. input.issue_key .. ':')

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

                output = table.concat(comments_output, '\n')
            end
        end
    elseif input.action == 'search' then
        if not input.jql_query then
            return '', 'jql_query is required for search action'
        end

        local search_endpoint = '/search?jql=' .. vim.uri_encode(input.jql_query) .. '&maxResults=50'
        local response, err = make_jira_request(config, 'GET', search_endpoint, nil)

        if err then
            error_msg = 'Failed to search issues: ' .. err
        else
            if response.errorMessages then
                error_msg = 'Jira API error: ' .. table.concat(response.errorMessages, ', ')
            else
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

                output = table.concat(search_output, '\n')
            end
        end
    else
        error_msg = 'Invalid action. Use: get_issue, get_transitions, transition, add_comment, get_comments, or search'
    end

    return output, error_msg
end

return M
