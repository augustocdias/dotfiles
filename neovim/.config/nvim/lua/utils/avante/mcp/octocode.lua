local wrap_schedule = require('utils').wrap_schedule
local mcp_client = require('utils.avante.mcp.client')
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

-- Global Octocode client instance
local octocode_client = nil
local client_ready = false

-- Get current project root
local function get_project_root()
    local cwd = vim.fn.getcwd()
    -- Try to find git root
    local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(cwd) .. ' rev-parse --show-toplevel')[1]
    if git_root and vim.v.shell_error == 0 then
        return git_root
    end
    return cwd
end

-- Initialize the Octocode MCP client
local function ensure_client()
    if octocode_client and client_ready then
        return true
    end

    if not octocode_client then
        local project_root = get_project_root()

        octocode_client = mcp_client.MCPClient.new('octocode', { 'octocode', 'mcp', '--path', project_root })

        -- Start the client
        if not octocode_client:start() then
            vim.notify('Failed to start Octocode MCP server', vim.log.levels.ERROR)
            return false
        end

        -- Initialize (this is async, but we'll handle it in the tool calls)
        octocode_client:initialize(function(success, error)
            if success then
                client_ready = true
                vim.notify('Octocode MCP client initialized for project: ' .. project_root, vim.log.levels.DEBUG)
            else
                vim.notify(
                    'Octocode initialization failed: ' .. (vim.inspect(error) or 'unknown error'),
                    vim.log.levels.ERROR
                )
            end
        end)
    end

    return octocode_client ~= nil
end

-- Avante tool for semantic search
function M.semantic_search_tool()
    return {
        name = 'octocode_semantic_search',
        description = 'Semantic search across codebase with multi-query support.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'query',
                    description = 'Search query (string) or multiple queries (array)',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'mode',
                    description = 'Search scope: "all", "code", "docs", "text"',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'detail_level',
                    description = 'Detail level: "signatures", "partial", "full"',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'max_results',
                    description = 'Maximum results to return (1-20)',
                    type = 'number',
                    optional = true,
                },
                {
                    name = 'threshold',
                    description = 'Similarity threshold (0.0-1.0)',
                    type = 'number',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'search_results',
                description = 'Semantic search results from the codebase',
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

            if not query then
                wrap_schedule(on_complete, false, 'query parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Octocode MCP client')
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log(
                    '🔍 Searching codebase for: ' .. (type(query) == 'table' and table.concat(query, ', ') or query)
                )

                local search_params = { query = query }
                if params.mode then
                    search_params.mode = params.mode
                end
                if params.detail_level then
                    search_params.detail_level = params.detail_level
                end
                if params.max_results then
                    search_params.max_results = params.max_results
                end
                if params.threshold then
                    search_params.threshold = params.threshold
                end

                octocode_client:call_tool('semantic_search', search_params, function(result, error)
                    if error then
                        wrap_schedule(
                            on_complete,
                            false,
                            'Failed to search codebase: ' .. (error.message or vim.inspect(error))
                        )
                        return
                    end

                    local response = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    response = response .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            response = result.content
                        end
                    end

                    on_log('✅ Search completed')

                    wrap_schedule(on_complete, response)
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for GraphRAG operations
function M.graphrag_tool()
    return {
        name = 'octocode_graphrag',
        description = 'Advanced relationship-aware GraphRAG operations for code analysis.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'operation',
                    description = 'Operation: "search", "get-node", "get-relationships", "find-path", "overview"',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'query',
                    description = 'Search query for "search" operation',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'node_id',
                    description = 'Node identifier for "get-node" and "get-relationships" operations',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'source_id',
                    description = 'Source node identifier for "find-path" operation',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'target_id',
                    description = 'Target node identifier for "find-path" operation',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'max_depth',
                    description = 'Maximum path depth for "find-path" operation',
                    type = 'number',
                    optional = true,
                },
                {
                    name = 'format',
                    description = 'Output format: "text", "json", "markdown"',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'max_tokens',
                    description = 'Maximum tokens in output',
                    type = 'number',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'graphrag_results',
                description = 'GraphRAG analysis results',
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
            local operation = params.operation

            if not operation then
                wrap_schedule(on_complete, false, 'operation parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Octocode MCP client')
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('🕸️ Performing GraphRAG operation: ' .. operation)

                local graphrag_params = { operation = operation }
                if params.query then
                    graphrag_params.query = params.query
                end
                if params.node_id then
                    graphrag_params.node_id = params.node_id
                end
                if params.source_id then
                    graphrag_params.source_id = params.source_id
                end
                if params.target_id then
                    graphrag_params.target_id = params.target_id
                end
                if params.max_depth then
                    graphrag_params.max_depth = params.max_depth
                end
                if params.format then
                    graphrag_params.format = params.format
                end
                if params.max_tokens then
                    graphrag_params.max_tokens = params.max_tokens
                end

                octocode_client:call_tool('graphrag', graphrag_params, function(result, error)
                    if error then
                        wrap_schedule(
                            on_complete,
                            false,
                            'Failed to perform GraphRAG operation: ' .. (error.message or vim.inspect(error))
                        )
                        return
                    end

                    local response = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    response = response .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            response = result.content
                        end
                    end

                    on_log('✅ GraphRAG operation completed')

                    wrap_schedule(on_complete, response)
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for memorizing information
function M.memorize_tool()
    return {
        name = 'octocode_memorize',
        description = 'Store important information for future reference.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'title',
                    description = 'Short descriptive title',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'content',
                    description = 'Detailed content to remember',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'memory_type',
                    description = 'Type of memory (code, bug_fix, feature, etc.)',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'importance',
                    description = 'Importance score 0.0-1.0',
                    type = 'number',
                    optional = true,
                },
                {
                    name = 'tags',
                    description = 'Tags for categorization',
                    type = 'array',
                    optional = true,
                    items = {
                        name = 'tag',
                        description = 'Tag name',
                        type = 'string',
                    },
                },
                {
                    name = 'related_files',
                    description = 'Related file paths',
                    type = 'array',
                    optional = true,
                    items = {
                        name = 'file_path',
                        description = 'File path',
                        type = 'string',
                    },
                },
            },
        },
        returns = {
            {
                name = 'memory_stored',
                description = 'Confirmation of stored memory',
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

            if not params.title or not params.content then
                wrap_schedule(on_complete, false, 'title and content parameters are required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Octocode MCP client')
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('💾 Storing memory: ' .. params.title)

                local memory_params = {
                    title = params.title,
                    content = params.content,
                }
                if params.memory_type then
                    memory_params.memory_type = params.memory_type
                end
                if params.importance then
                    memory_params.importance = params.importance
                end
                if params.tags then
                    memory_params.tags = params.tags
                end
                if params.related_files then
                    memory_params.related_files = params.related_files
                end

                octocode_client:call_tool('memorize', memory_params, function(result, error)
                    if error then
                        wrap_schedule(
                            on_complete,
                            false,
                            'Failed to store memory: ' .. (error.message or vim.inspect(error))
                        )
                        return
                    end

                    local response = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    response = response .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            response = result.content
                        end
                    end

                    on_log('✅ Memory stored successfully')

                    wrap_schedule(on_complete, response)
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for remembering information
function M.remember_tool()
    return {
        name = 'octocode_remember',
        description = 'Retrieve stored information with semantic search.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'query',
                    description = 'Search query (string) or multiple related queries (array)',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'memory_types',
                    description = 'Filter by memory types',
                    type = 'array',
                    optional = true,
                    items = {
                        name = 'memory_type',
                        description = 'A type for the memory',
                        type = 'string',
                    },
                },
                {
                    name = 'tags',
                    description = 'Filter by tags',
                    type = 'array',
                    optional = true,
                    items = {
                        name = 'tag',
                        description = 'Tag name',
                        type = 'string',
                    },
                },
                {
                    name = 'related_files',
                    description = 'Filter by related files',
                    type = 'array',
                    optional = true,
                    items = {
                        name = 'file_path',
                        description = 'File path',
                        type = 'string',
                    },
                },
                {
                    name = 'limit',
                    description = 'Maximum memories to return',
                    type = 'number',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'memories',
                description = 'Retrieved memories matching the query',
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

            if not params.query then
                wrap_schedule(on_complete, false, 'query parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Octocode MCP client')
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log(
                    '🧠 Retrieving memories for: '
                        .. (type(params.query) == 'table' and table.concat(params.query, ', ') or params.query)
                )

                local remember_params = { query = params.query }
                if params.memory_types then
                    remember_params.memory_types = params.memory_types
                end
                if params.tags then
                    remember_params.tags = params.tags
                end
                if params.related_files then
                    remember_params.related_files = params.related_files
                end
                if params.limit then
                    remember_params.limit = params.limit
                end

                octocode_client:call_tool('remember', remember_params, function(result, error)
                    if error then
                        wrap_schedule(
                            on_complete,
                            false,
                            'Failed to retrieve memories: ' .. (error.message or vim.inspect(error))
                        )
                        return
                    end

                    local response = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    response = response .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            response = result.content
                        end
                    end

                    on_log('✅ Memories retrieved')

                    wrap_schedule(on_complete, response)
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for forgetting information
function M.forget_tool()
    return {
        name = 'octocode_forget',
        description = 'Remove stored information from memory.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'memory_id',
                    description = 'Specific memory ID to forget',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'query',
                    description = 'Query to find memories to forget',
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'memory_types',
                    description = 'Filter by memory types when using query',
                    type = 'array',
                    optional = true,
                    items = {
                        name = 'memory_type',
                        description = 'Memory type to filter',
                        type = 'string',
                    },
                },
                {
                    name = 'tags',
                    description = 'Filter by tags when using query',
                    type = 'array',
                    optional = true,
                    items = {
                        name = 'tag',
                        description = 'Tag name',
                        type = 'string',
                    },
                },
                {
                    name = 'confirm',
                    description = 'Must be true to confirm deletion',
                    type = 'boolean',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'forget_result',
                description = 'Result of the forget operation',
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

            if not params.confirm then
                wrap_schedule(on_complete, false, 'confirm parameter must be true to proceed with deletion')
                return
            end

            if not params.memory_id and not params.query then
                wrap_schedule(on_complete, false, 'Either memory_id or query parameter is required')
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, false, 'Failed to initialize Octocode MCP client')
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                local log_msg = params.memory_id and ('🗑️ Forgetting memory: ' .. params.memory_id)
                    or ('🗑️ Forgetting memories matching: ' .. params.query)
                on_log(log_msg)

                local forget_params = { confirm = params.confirm }
                if params.memory_id then
                    forget_params.memory_id = params.memory_id
                end
                if params.query then
                    forget_params.query = params.query
                end
                if params.memory_types then
                    forget_params.memory_types = params.memory_types
                end
                if params.tags then
                    forget_params.tags = params.tags
                end

                octocode_client:call_tool('forget', forget_params, function(result, error)
                    if error then
                        wrap_schedule(
                            on_complete,
                            false,
                            'Failed to forget memories: ' .. (error.message or vim.inspect(error))
                        )
                        return
                    end

                    local response = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    response = response .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            response = result.content
                        end
                    end

                    on_log('✅ Memories forgotten')

                    wrap_schedule(on_complete, response)
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Cleanup function
function M.cleanup()
    if octocode_client then
        octocode_client:stop()
        octocode_client = nil
        client_ready = false
    end
end

return M
