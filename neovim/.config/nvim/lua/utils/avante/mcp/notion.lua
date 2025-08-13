local mcp_client = require('utils.avante.mcp.client')

local wrap_schedule = function(func, args)
    vim.schedule(function()
        func(args)
    end)
end

local M = {}

-- Global Notion client instance
local notion_client = nil
local client_ready = false

-- Initialize the Notion MCP client
local function ensure_client()
    if notion_client and client_ready then
        return true
    end

    if not notion_client then
        -- Using the Notion MCP server from the system prompt
        notion_client = mcp_client.MCPClient.new('notion', { 'npx', '-y', 'mcp-remote', 'https://mcp.notion.com/mcp' })

        -- Start the client
        if not notion_client:start() then
            vim.notify('Failed to start Notion MCP server', vim.log.levels.ERROR)
            return false
        end

        -- Initialize (this is async, but we'll handle it in the tool calls)
        notion_client:initialize(function(success, error)
            if success then
                client_ready = true
                vim.notify('Notion MCP client initialized', vim.log.levels.DEBUG)
            else
                vim.notify(
                    'Notion initialization failed: ' .. (vim.inspect(error) or 'unknown error'),
                    vim.log.levels.ERROR
                )
            end
        end)
    end

    return notion_client ~= nil
end

-- Avante tool for searching Notion workspace
function M.search_tool()
    return {
        name = 'notion_search',
        description = 'Search over your entire Notion workspace and connected sources (Slack, Google Drive, Github, Jira, etc.). Use this to find information, pages, databases, or users.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'query',
                    description = 'Search query - can be semantic search or keyword/substring for users',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'query_type',
                    description = 'Type of search: "internal" for content search or "user" for user search',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'page_url',
                    description = 'Optional: URL or ID of page to search within',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'data_source_url',
                    description = 'Optional: URL of Data source to search within',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'teamspace_id',
                    description = 'Optional: Teamspace ID to restrict search to',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'results',
                description = 'Search results with titles, URLs, and highlights',
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
            local query = params.query
            local query_type = params.query_type or 'internal'

            if not query then
                wrap_schedule(on_complete, {
                    error = 'query parameter is required',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Notion MCP client',
                })
                return
            end

            local function wait_and_search()
                if not client_ready then
                    vim.defer_fn(wait_and_search, 100)
                    return
                end

                on_log('🔍 Searching Notion for: ' .. query)

                local search_args = {
                    query = query,
                    query_type = query_type,
                }

                -- Add optional parameters if provided
                if params.page_url then
                    search_args.page_url = params.page_url
                end
                if params.data_source_url then
                    search_args.data_source_url = params.data_source_url
                end
                if params.teamspace_id then
                    search_args.teamspace_id = params.teamspace_id
                end

                notion_client:call_tool('search', search_args, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to search Notion: ' .. (error.message or 'unknown error'),
                        })
                        return
                    end

                    local results = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    results = results .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            results = result.content
                        end
                    end

                    if results == '' then
                        wrap_schedule(on_complete, {
                            error = 'No results found for: ' .. query,
                        })
                        return
                    end

                    on_log('✅ Found Notion results for: ' .. query)
                    wrap_schedule(on_complete, {
                        results = results,
                    })
                end)
            end

            wait_and_search()
        end,
    }
end

-- Avante tool for fetching Notion pages/databases
function M.fetch_tool()
    return {
        name = 'notion_fetch',
        description = 'Fetch details about a Notion page or database by its URL or ID. Use this to get the full content of a specific page or database.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'id',
                    description = 'The URL or ID of the Notion page/database to fetch',
                    type = 'string',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'content',
                description = 'The fetched page/database content in enhanced Markdown format',
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
            local id = params.id

            if not id then
                wrap_schedule(on_complete, {
                    error = 'id parameter is required',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Notion MCP client',
                })
                return
            end

            local function wait_and_fetch()
                if not client_ready then
                    vim.defer_fn(wait_and_fetch, 100)
                    return
                end

                on_log('📄 Fetching Notion content for: ' .. id)

                notion_client:call_tool('fetch', { id = id }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to fetch Notion content: ' .. (error.message or 'unknown error'),
                        })
                        return
                    end

                    local content = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    content = content .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            content = result.content
                        end
                    end

                    if content == '' then
                        wrap_schedule(on_complete, {
                            error = 'No content found for: ' .. id,
                        })
                        return
                    end

                    on_log('✅ Fetched Notion content successfully (' .. #content .. ' characters)')
                    wrap_schedule(on_complete, {
                        content = content,
                    })
                end)
            end

            wait_and_fetch()
        end,
    }
end

-- Cleanup function
function M.cleanup()
    if notion_client then
        notion_client:stop()
        notion_client = nil
        client_ready = false
    end
end

return M
