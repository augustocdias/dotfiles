local mcp_client = require('utils.avante.mcp.client')

local M = {}

local wrap_schedule = function(func, args)
    vim.schedule(function()
        func(args)
    end)
end

-- Global Context7 client instance
local context7_client = nil
local client_ready = false

-- Initialize the Context7 MCP client
local function ensure_client()
    if context7_client and client_ready then
        return true
    end

    if not context7_client then
        context7_client = mcp_client.MCPClient.new('context7', { 'npx', '-y', '@upstash/context7-mcp' })

        -- Start the client
        if not context7_client:start() then
            vim.notify('Failed to start Context7 MCP server', vim.log.levels.ERROR)
            return false
        end

        -- Initialize (this is async, but we'll handle it in the tool calls)
        context7_client:initialize(function(success, error)
            if success then
                client_ready = true
                vim.notify('Context7 MCP client initialized', vim.log.levels.DEBUG)
            else
                vim.notify(
                    'Context7 initialization failed: ' .. (vim.inspect(error) or 'unknown error'),
                    vim.log.levels.ERROR
                )
            end
        end)
    end

    return context7_client ~= nil
end

-- Avante tool for getting library documentation
function M.get_library_docs_tool()
    return {
        name = 'context7_get_docs',
        description = 'Get up-to-date documentation for any programming library, framework, or package. This tool fetches the latest documentation directly from the source, ensuring accuracy and currency.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'library_id',
                    description = 'Id of the library retrieved from the context7_resolve_library tool',
                    type = 'string',
                    required = true,
                },
                {
                    name = 'topic',
                    description = "Optional: Specific topic to focus on (e.g., 'hooks', 'routing', 'authentication')",
                    type = 'string',
                    optional = true,
                },
                {
                    name = 'max_tokens',
                    description = 'Optional: Maximum number of tokens to return (default: 10000)',
                    type = 'number',
                    optional = true,
                },
            },
        },
        returns = {
            {
                name = 'documentation',
                description = 'The fetched documentation content',
                type = 'string',
            },
            {
                name = 'library_id',
                description = 'The resolved Context7 library identifier',
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
            local library_id = params.library_id
            local topic = params.topic
            local max_tokens = params.max_tokens or 10000

            if not library_id then
                wrap_schedule(on_complete, {
                    error = 'library_id parameter is required',
                })
                return
            end

            -- Ensure client is ready
            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Context7 MCP client',
                })
                return
            end

            -- Wait for client to be ready if it's still initializing
            local function wait_and_resolve()
                if not client_ready then
                    vim.defer_fn(wait_and_resolve, 100)
                    return
                end

                -- Step 1: Resolve library ID
                on_log('📚 Fetching documentation for library id: ' .. library_id)
                local doc_args = {
                    context7CompatibleLibraryID = library_id,
                    tokens = max_tokens,
                }

                if topic then
                    doc_args.topic = topic
                    on_log('🎯 Focusing on topic: ' .. topic)
                end

                context7_client:call_tool('get-library-docs', doc_args, function(docs_result, docs_error)
                    if docs_error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to fetch documentation: ' .. (docs_error.message or 'unknown error'),
                            library_id = library_id,
                        })
                        return
                    end

                    -- Extract documentation content
                    local documentation = ''
                    if docs_result and docs_result.content then
                        if type(docs_result.content) == 'table' then
                            for _, item in ipairs(docs_result.content) do
                                if item.text then
                                    documentation = documentation .. item.text .. '\n'
                                end
                            end
                        elseif type(docs_result.content) == 'string' then
                            documentation = docs_result.content
                        end
                    end

                    if documentation == '' then
                        wrap_schedule(on_complete, {
                            error = 'No documentation content found for ' .. library_id,
                            library_id = library_id,
                        })
                        return
                    end

                    on_log('✅ Documentation fetched successfully (' .. #documentation .. ' characters)')

                    wrap_schedule(on_complete, {
                        documentation = documentation,
                        library_id = library_id,
                    })
                end)
            end

            wait_and_resolve()
        end,
    }
end

-- Avante tool for resolving library names to Context7 IDs
function M.resolve_library_tool()
    return {
        name = 'context7_resolve_library',
        description = 'Resolve a library name to its Context7-compatible identifier. Useful when you need to know what libraries are available or get the exact ID for a library.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'library_name',
                    description = "Name of the library to resolve (e.g., 'react', 'vue', 'django')",
                    type = 'string',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'matches',
                description = 'List of matching libraries with their Context7 IDs and descriptions',
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
            local library_name = params.library_name

            if not library_name then
                wrap_schedule(on_complete, {
                    error = 'library_name parameter is required',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Context7 MCP client',
                })
                return
            end

            on_log('🔍 Searching for libraries matching: ' .. library_name)

            local function wait_and_resolve()
                if not client_ready then
                    vim.defer_fn(wait_and_resolve, 100)
                    return
                end

                context7_client:call_tool('resolve-library-id', {
                    libraryName = library_name,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to resolve library: ' .. (error.message or 'unknown error'),
                        })
                        return
                    end

                    local matches = ''
                    if result and result.content then
                        if type(result.content) == 'table' then
                            for _, item in ipairs(result.content) do
                                if item.text then
                                    matches = matches .. item.text .. '\n'
                                end
                            end
                        elseif type(result.content) == 'string' then
                            matches = result.content
                        end
                    end

                    if matches == '' then
                        wrap_schedule(on_complete, {
                            error = "No matches found for '" .. library_name .. "'",
                        })
                        return
                    end

                    on_log('✅ Found matches for: ' .. library_name)

                    wrap_schedule(on_complete, {
                        matches = matches,
                    })
                end)
            end

            wait_and_resolve()
        end,
    }
end

-- Cleanup function
function M.cleanup()
    if context7_client then
        context7_client:stop()
        context7_client = nil
        client_ready = false
    end
end

return M
