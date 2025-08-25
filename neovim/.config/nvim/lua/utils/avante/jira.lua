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
    local config, config_error = get_jira_config()
    if config_error then
        return '', config_error
    end

    if on_log then
        on_log('Jira URL: ' .. config.url)
        on_log('Action: ' .. input.action)
    end

    if input.action == 'get_issue' then
        if not input.issue_key then
            on_complete(false, 'issue_key is required for get_issue action')
            return
        end

        local response, err = make_jira_request(config, 'GET', '/issue/' .. input.issue_key, nil)
        if err then
            on_complete(false, 'Failed to get issue: ' .. err)
        else
            if response.errorMessages then
                on_complete(false, 'Jira API error: ' .. table.concat(response.errorMessages, ', '))
            else
                on_complete(format_issue_output(response), nil)
            end
        end
    elseif input.action == 'get_transitions' then
        if not input.issue_key then
            on_complete(false, 'issue_key is required for get_transitions action')
            return
        end

        local response, err = make_jira_request(config, 'GET', '/issue/' .. input.issue_key .. '/transitions', nil)
        if err then
            on_complete(false, 'Failed to get transitions: ' .. err)
        else
            if response.errorMessages then
                on_complete(false, 'Jira API error: ' .. table.concat(response.errorMessages, ', '))
            else
                on_complete(format_transitions_output(response), nil)
            end
        end
    elseif input.action == 'transition' then
        if not input.issue_key then
            on_complete(false, 'issue_key is required for transition action')
            return
        end
        if not input.transition_id then
            on_complete(false, 'transition_id is required for transition action')
            return
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
                on_complete(false, 'Invalid JSON in fields parameter: ' .. input.fields)
                return
            end
        end

        -- Get transitions to find the target status name
        local transitions_response, transitions_err =
            make_jira_request(config, 'GET', '/issue/' .. input.issue_key .. '/transitions', nil)

        local target_status_name = input.transition_id -- fallback to ID if we can't find name
        if not transitions_err and transitions_response and transitions_response.transitions then
            for _, transition in ipairs(transitions_response.transitions) do
                if transition.id == input.transition_id then
                    target_status_name = transition.to and transition.to.name or transition.name
                    break
                end
            end
        end

        local body_json = vim.json.encode(transition_body)
        Helpers.confirm(
            'Are you sure you want to transition issue ' .. input.issue_key .. ' to "' .. target_status_name .. '"?',
            function(ok, reason)
                if not ok then
                    on_complete(false, 'User declined, reason: ' .. (reason or 'unknown'))
                    return
                end
                local response, err =
                    make_jira_request(config, 'POST', '/issue/' .. input.issue_key .. '/transitions', body_json)

                if err then
                    on_complete(false, 'Failed to transition issue: ' .. err)
                else
                    if response and response.errorMessages then
                        on_complete(false, 'Jira API error: ' .. table.concat(response.errorMessages, ', '))
                    else
                        on_complete(

                            'Successfully transitioned issue '
                                .. input.issue_key
                                .. ' to "'
                                .. target_status_name
                                .. '"',
                            nil
                        )
                    end
                end
            end,
            nil,
            opts.session_ctx,
            'jira'
        )
    elseif input.action == 'add_comment' then
        if not input.issue_key then
            on_complete(false, 'issue_key is required for add_comment action')
            return
        end
        if not input.comment_text then
            on_complete(false, 'comment_text is required for add_comment action')
            return
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
            function(ok, reason)
                if not ok then
                    on_complete(false, 'User declined, reason: ' .. (reason or 'unknown'))
                    return
                end
                local response, err =
                    make_jira_request(config, 'POST', '/issue/' .. input.issue_key .. '/comment', body_json)

                if err then
                    on_complete(false, 'Failed to add comment: ' .. err)
                else
                    if response and response.errorMessages then
                        on_complete(false, 'Jira API error: ' .. table.concat(response.errorMessages, ', '))
                    else
                        local output = 'Successfully added comment to issue ' .. input.issue_key
                        if response and response.id then
                            output = output .. ' (Comment ID: ' .. response.id .. ')'
                        end
                        on_complete(output, nil)
                    end
                end
            end,
            nil,
            opts.session_ctx,
            'jira'
        )
        return
    elseif input.action == 'get_comments' then
        if not input.issue_key then
            on_complete(false, 'issue_key is required for get_comments action')
            return
        end

        local response, err = make_jira_request(config, 'GET', '/issue/' .. input.issue_key .. '/comment', nil)
        if err then
            on_complete(false, 'Failed to get comments: ' .. err)
        else
            if response.errorMessages then
                on_complete(false, 'Jira API error: ' .. table.concat(response.errorMessages, ', '))
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

                on_complete(table.concat(comments_output, '\n'), nil)
            end
        end
    elseif input.action == 'search' then
        if not input.jql_query then
            on_complete(false, 'jql_query is required for search action')
            return
        end

        local search_endpoint = '/search?jql=' .. vim.uri_encode(input.jql_query) .. '&maxResults=50'
        local response, err = make_jira_request(config, 'GET', search_endpoint, nil)

        if err then
            on_complete(false, 'Failed to search issues: ' .. err)
        else
            if response.errorMessages then
                on_complete(false, 'Jira API error: ' .. table.concat(response.errorMessages, ', '))
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

                on_complete(table.concat(search_output, '\n'), nil)
            end
        end
    else
        on_complete(
            false,
            'Invalid action. Use: get_issue, get_transitions, transition, add_comment, get_comments, or search'
        )
    end
end

return M
