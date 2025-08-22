local wrap_schedule = require('utils').wrap_schedule
local Helpers = require('avante.llm_tools.helpers')
local Base = require('avante.llm_tools.base')
local mcp_client = require('utils.avante.mcp.client')

local M = setmetatable({}, Base)

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
                wrap_schedule(on_complete, false, 'query parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
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
                        wrap_schedule(on_complete, false, 'Failed to search Notion: ' .. (error.message or 'unknown error'))
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
                        wrap_schedule(on_complete, false, 'No results found for: ' .. query)
                        return
                    end

                    on_log('✅ Found Notion results for: ' .. query)
                    wrap_schedule(on_complete, results)
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
                wrap_schedule(on_complete, false, 'id parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
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
                        wrap_schedule(on_complete, false, 'Failed to fetch Notion content: ' .. (error.message or 'unknown error'))
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
                        wrap_schedule(on_complete, false, 'No content found for: ' .. id)
                        return
                    end

                    on_log('✅ Fetched Notion content successfully (' .. #content .. ' characters)')
                    wrap_schedule(on_complete, content)
                end)
            end

            wait_and_fetch()
        end,
    }
end

-- Avante tool for creating Notion pages (requires confirmation)
function M.create_pages_tool()
    return {
        name = 'notion_create_pages',
        description = 'Creates one or more Notion pages with specified properties and content. If a parent is not specified, a private page will be created.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'pages',
                    description = 'Array of page objects to create, each with title, content, and optional parent/properties',
                    type = 'string', -- JSON string
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'results',
                description = 'Created page URLs and details',
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

            if not params.pages then
                wrap_schedule(on_complete, false, 'pages parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            -- Request user confirmation before creating pages
            Helpers.confirm('Are you sure you want to create new Notion pages?', function(ok, reason)
                if not ok then
                    wrap_schedule(on_complete, false, 'User declined page creation: ' .. (reason or 'unknown'))
                    return
                end

                local function wait_and_create()
                    if not client_ready then
                        vim.defer_fn(wait_and_create, 100)
                        return
                    end

                    on_log('📝 Creating Notion pages...')

                    notion_client:call_tool('create-pages', { pages = params.pages }, function(result, error)
                        if error then
                            wrap_schedule(on_complete, false, 'Failed to create pages: ' .. (error.message or 'unknown error'))
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

                        on_log('✅ Created Notion pages successfully')
                        wrap_schedule(on_complete, results)
                    end)
                end

                wait_and_create()
            end)
        end,
    }
end

-- Avante tool for updating Notion pages (requires confirmation)
function M.update_page_tool()
    return {
        name = 'notion_update_page',
        description = "Update a Notion page's properties or content.",
        param = {
            type = 'table',
            fields = {
                {
                    name = 'page_id',
                    description = 'The ID or URL of the page to update',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'properties',
                    description = 'Optional: Page properties to update as JSON string',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'content',
                    description = 'Optional: New content to append/replace in Markdown format',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'result',
                description = 'Update confirmation and page details',
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

            if not params.page_id then
                wrap_schedule(on_complete, false, 'page_id parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            -- Request user confirmation before updating page
            Helpers.confirm(
                'Are you sure you want to update the Notion page: ' .. params.page_id .. '?',
                function(ok, reason)
                    if not ok then
                        wrap_schedule(on_complete, false, 'User declined page update: ' .. (reason or 'unknown'))
                        return
                    end

                    local function wait_and_update()
                        if not client_ready then
                            vim.defer_fn(wait_and_update, 100)
                            return
                        end

                        on_log('📝 Updating Notion page: ' .. params.page_id)

                        local update_args = {
                            page_id = params.page_id,
                        }

                        if params.properties then
                            update_args.properties = params.properties
                        end
                        if params.content then
                            update_args.content = params.content
                        end

                        notion_client:call_tool('update-page', update_args, function(result, error)
                            if error then
                                wrap_schedule(on_complete, false, 'Failed to update page: ' .. (error.message or 'unknown error'))
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

                            on_log('✅ Updated Notion page successfully')
                            wrap_schedule(on_complete, results)
                        end)
                    end

                    wait_and_update()
                end
            )
        end,
    }
end

-- Avante tool for moving Notion pages (requires confirmation)
function M.move_pages_tool()
    return {
        name = 'notion_move_pages',
        description = 'Move one or more Notion pages or databases to a new parent.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'page_ids',
                    description = 'Array of page/database IDs to move (as JSON string)',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'parent_id',
                    description = 'ID of the new parent page/database',
                    type = 'string',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'result',
                description = 'Move operation results',
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

            if not params.page_ids or not params.parent_id then
                wrap_schedule(on_complete, false, 'page_ids and parent_id parameters are required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            -- Request user confirmation before moving pages
            Helpers.confirm(
                'Are you sure you want to move pages to parent: ' .. params.parent_id .. '?',
                function(ok, reason)
                    if not ok then
                        wrap_schedule(on_complete, false, 'User declined page move: ' .. (reason or 'unknown'))
                        return
                    end

                    local function wait_and_move()
                        if not client_ready then
                            vim.defer_fn(wait_and_move, 100)
                            return
                        end

                        on_log('📁 Moving Notion pages to new parent...')

                        notion_client:call_tool('move-pages', {
                            page_ids = params.page_ids,
                            parent_id = params.parent_id,
                        }, function(result, error)
                            if error then
                                wrap_schedule(on_complete, false, 'Failed to move pages: ' .. (error.message or 'unknown error'))
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

                            on_log('✅ Moved pages successfully')
                            wrap_schedule(on_complete, results)
                        end)
                    end

                    wait_and_move()
                end
            )
        end,
    }
end

-- Avante tool for duplicating Notion pages (requires confirmation)
function M.duplicate_page_tool()
    return {
        name = 'notion_duplicate_page',
        description = 'Duplicate a Notion page within your workspace. This action is completed async.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'page_id',
                    description = 'The ID or URL of the page to duplicate',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'title',
                    description = 'Optional: Title for the duplicated page',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'result',
                description = 'Duplication result and new page details',
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

            if not params.page_id then
                wrap_schedule(on_complete, false, 'page_id parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            -- Request user confirmation before duplicating page
            Helpers.confirm(
                'Are you sure you want to duplicate the Notion page: ' .. params.page_id .. '?',
                function(ok, reason)
                    if not ok then
                        wrap_schedule(on_complete, false, 'User declined page duplication: ' .. (reason or 'unknown'))
                        return
                    end

                    local function wait_and_duplicate()
                        if not client_ready then
                            vim.defer_fn(wait_and_duplicate, 100)
                            return
                        end

                        on_log('📋 Duplicating Notion page: ' .. params.page_id)

                        local duplicate_args = {
                            page_id = params.page_id,
                        }

                        if params.title then
                            duplicate_args.title = params.title
                        end

                        notion_client:call_tool('duplicate-page', duplicate_args, function(result, error)
                            if error then
                                wrap_schedule(on_complete, false, 'Failed to duplicate page: ' .. (error.message or 'unknown error'))
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

                            on_log('✅ Duplicated page successfully')
                            wrap_schedule(on_complete, results)
                        end)
                    end

                    wait_and_duplicate()
                end
            )
        end,
    }
end

-- Avante tool for creating Notion databases (requires confirmation)
function M.create_database_tool()
    return {
        name = 'notion_create_database',
        description = 'Creates a new Notion database with the specified properties.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'title',
                    description = 'Database title',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'parent_id',
                    description = 'Parent page ID where database should be created',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'properties',
                    description = 'Database schema properties as JSON string',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'description',
                    description = 'Optional: Database description',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'result',
                description = 'Created database details and URL',
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

            if not params.title or not params.parent_id or not params.properties then
                wrap_schedule(on_complete, false, 'title, parent_id, and properties parameters are required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            -- Request user confirmation before creating database
            Helpers.confirm(
                'Are you sure you want to create a new Notion database: ' .. params.title .. '?',
                function(ok, reason)
                    if not ok then
                        wrap_schedule(on_complete, false, 'User declined database creation: ' .. (reason or 'unknown'))
                        return
                    end

                    local function wait_and_create_db()
                        if not client_ready then
                            vim.defer_fn(wait_and_create_db, 100)
                            return
                        end

                        on_log('🗄️ Creating Notion database: ' .. params.title)

                        local create_args = {
                            title = params.title,
                            parent_id = params.parent_id,
                            properties = params.properties,
                        }

                        if params.description then
                            create_args.description = params.description
                        end

                        notion_client:call_tool('create-database', create_args, function(result, error)
                            if error then
                                wrap_schedule(on_complete, false, 'Failed to create database: ' .. (error.message or 'unknown error'))
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

                            on_log('✅ Created database successfully')
                            wrap_schedule(on_complete, results)
                        end)
                    end

                    wait_and_create_db()
                end
            )
        end,
    }
end

-- Avante tool for updating Notion databases (requires confirmation)
function M.update_database_tool()
    return {
        name = 'notion_update_database',
        description = "Update a Notion database's properties, name, description, or other attributes.",
        param = {
            type = 'table',
            fields = {
                {
                    name = 'database_id',
                    description = 'The ID of the database to update',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'title',
                    description = 'Optional: New database title',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'description',
                    description = 'Optional: New database description',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'properties',
                    description = 'Optional: Updated properties schema as JSON string',
                    type = 'string',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'result',
                description = 'Update confirmation and database details',
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

            if not params.database_id then
                wrap_schedule(on_complete, false, 'database_id parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            -- Request user confirmation before updating database
            Helpers.confirm(
                'Are you sure you want to update the Notion database: ' .. params.database_id .. '?',
                function(ok, reason)
                    if not ok then
                        wrap_schedule(on_complete, false, 'User declined database update: ' .. (reason or 'unknown'))
                        return
                    end

                    local function wait_and_update_db()
                        if not client_ready then
                            vim.defer_fn(wait_and_update_db, 100)
                            return
                        end

                        on_log('🗄️ Updating Notion database: ' .. params.database_id)

                        local update_args = {
                            database_id = params.database_id,
                        }

                        if params.title then
                            update_args.title = params.title
                        end
                        if params.description then
                            update_args.description = params.description
                        end
                        if params.properties then
                            update_args.properties = params.properties
                        end

                        notion_client:call_tool('update-database', update_args, function(result, error)
                            if error then
                                wrap_schedule(on_complete, false, 'Failed to update database: ' .. (error.message or 'unknown error'))
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

                            on_log('✅ Updated database successfully')
                            wrap_schedule(on_complete, results)
                        end)
                    end

                    wait_and_update_db()
                end
            )
        end,
    }
end

-- Avante tool for creating comments (requires confirmation)
function M.create_comment_tool()
    return {
        name = 'notion_create_comment',
        description = 'Add a comment to a page',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'page_id',
                    description = 'The ID of the page to comment on',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'comment',
                    description = 'The comment text to add',
                    type = 'string',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'result',
                description = 'Comment creation confirmation',
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

            if not params.page_id or not params.comment then
                wrap_schedule(on_complete, false, 'page_id and comment parameters are required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            -- Request user confirmation before creating comment
            Helpers.confirm(
                'Are you sure you want to add a comment to page: ' .. params.page_id .. '?',
                function(ok, reason)
                    if not ok then
                        wrap_schedule(on_complete, false, 'User declined comment creation: ' .. (reason or 'unknown'))
                        return
                    end

                    local function wait_and_comment()
                        if not client_ready then
                            vim.defer_fn(wait_and_comment, 100)
                            return
                        end

                        on_log('💬 Adding comment to page: ' .. params.page_id)

                        notion_client:call_tool('create-comment', {
                            page_id = params.page_id,
                            comment = params.comment,
                        }, function(result, error)
                            if error then
                                wrap_schedule(on_complete, false, 'Failed to create comment: ' .. (error.message or 'unknown error'))
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

                            on_log('✅ Added comment successfully')
                            wrap_schedule(on_complete, results)
                        end)
                    end

                    wait_and_comment()
                end
            )
        end,
    }
end

-- Avante tool for getting comments (read-only, no confirmation needed)
function M.get_comments_tool()
    return {
        name = 'notion_get_comments',
        description = 'Lists all comments on a specific page, including threaded discussions.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'page_id',
                    description = 'The ID of the page to get comments from',
                    type = 'string',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'comments',
                description = 'List of comments with authors and timestamps',
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

            if not params.page_id then
                wrap_schedule(on_complete, false, 'page_id parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            local function wait_and_get_comments()
                if not client_ready then
                    vim.defer_fn(wait_and_get_comments, 100)
                    return
                end

                on_log('💬 Getting comments for page: ' .. params.page_id)

                notion_client:call_tool('get-comments', {
                    page_id = params.page_id,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, false, 'Failed to get comments: ' .. (error.message or 'unknown error'))
                        return
                    end

                    local comments = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    comments = comments .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            comments = result.content
                        end
                    end

                    on_log('✅ Retrieved comments successfully')
                    wrap_schedule(on_complete, comments)
                end)
            end

            wait_and_get_comments()
        end,
    }
end

-- Avante tool for listing users (read-only, no confirmation needed)
function M.get_users_tool()
    return {
        name = 'notion_get_users',
        description = 'Lists all users in the workspace with their details.',
        param = {
            type = 'table',
            fields = {},
        },
        returns = {
            {
                name = 'users',
                description = 'List of workspace users with details',
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

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            local function wait_and_get_users()
                if not client_ready then
                    vim.defer_fn(wait_and_get_users, 100)
                    return
                end

                on_log('👥 Getting workspace users...')

                notion_client:call_tool('get-users', {}, function(result, error)
                    if error then
                        wrap_schedule(on_complete, false, 'Failed to get users: ' .. (error.message or 'unknown error'))
                        return
                    end

                    local users = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    users = users .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            users = result.content
                        end
                    end

                    on_log('✅ Retrieved users successfully')
                    wrap_schedule(on_complete, users)
                end)
            end

            wait_and_get_users()
        end,
    }
end

-- Avante tool for getting specific user (read-only, no confirmation needed)
function M.get_user_tool()
    return {
        name = 'notion_get_user',
        description = 'Retrieve your user information by ID',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'user_id',
                    description = 'The ID of the user to retrieve',
                    type = 'string',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'user',
                description = 'User details and information',
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

            if not params.user_id then
                wrap_schedule(on_complete, false, 'user_id parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            local function wait_and_get_user()
                if not client_ready then
                    vim.defer_fn(wait_and_get_user, 100)
                    return
                end

                on_log('👤 Getting user: ' .. params.user_id)

                notion_client:call_tool('get-user', {
                    user_id = params.user_id,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, false, 'Failed to get user: ' .. (error.message or 'unknown error'))
                        return
                    end

                    local user = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    user = user .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            user = result.content
                        end
                    end

                    on_log('✅ Retrieved user successfully')
                    wrap_schedule(on_complete, user)
                end)
            end

            wait_and_get_user()
        end,
    }
end

-- Avante tool for getting self info (read-only, no confirmation needed)
function M.get_self_tool()
    return {
        name = 'notion_get_self',
        description = "Retrieves information about your own bot user and the Notion workspace you're connected to.",
        param = {
            type = 'table',
            fields = {},
        },
        returns = {
            {
                name = 'self_info',
                description = 'Your user info and workspace details',
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

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Notion MCP client')
                return
            end

            local function wait_and_get_self()
                if not client_ready then
                    vim.defer_fn(wait_and_get_self, 100)
                    return
                end

                on_log('👤 Getting self information...')

                notion_client:call_tool('get-self', {}, function(result, error)
                    if error then
                        wrap_schedule(on_complete, false, 'Failed to get self info: ' .. (error.message or 'unknown error'))
                        return
                    end

                    local self_info = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    self_info = self_info .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            self_info = result.content
                        end
                    end

                    on_log('✅ Retrieved self info successfully')
                    wrap_schedule(on_complete, self_info)
                end)
            end

            wait_and_get_self()
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
