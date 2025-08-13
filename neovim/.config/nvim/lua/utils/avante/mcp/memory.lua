local mcp_client = require('utils.avante.mcp.client')

local M = {}

local wrap_schedule = function(func, args)
    vim.schedule(function()
        func(args)
    end)
end

-- Global Memory client instance
local memory_client = nil
local client_ready = false

-- Initialize the Memory MCP client
local function ensure_client()
    if memory_client and client_ready then
        return true
    end

    if not memory_client then
        memory_client = mcp_client.MCPClient.new('memory', { 'npx', '-y', '@modelcontextprotocol/server-memory' })

        -- Start the client
        if not memory_client:start() then
            vim.notify('Failed to start Memory MCP server', vim.log.levels.ERROR)
            return false
        end

        -- Initialize (this is async, but we'll handle it in the tool calls)
        memory_client:initialize(function(success, error)
            if success then
                client_ready = true
                vim.notify('Memory MCP client initialized', vim.log.levels.DEBUG)
            else
                vim.notify(
                    'Memory initialization failed: ' .. (vim.inspect(error) or 'unknown error'),
                    vim.log.levels.ERROR
                )
            end
        end)
    end

    return memory_client ~= nil
end

-- Avante tool for creating entities
function M.create_entities_tool()
    return {
        name = 'memory_create_entities',
        description = 'Create multiple new entities in the knowledge graph. Each entity has a name, type, and observations.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'entities',
                    description = 'Array of entities to create. Each entity should have name, entityType, and observations fields.',
                    type = 'array',
                    required = true,
                    items = {
                        name = 'requestObj',
                        description = 'Item array',
                        type = 'object',
                        fields = {
                            {
                                name = 'name',
                                description = 'Entity identifier',
                                type = 'string',
                                required = true,
                            },
                            {
                                name = 'entityType',
                                description = 'Type classification',
                                type = 'string',
                                required = true,
                            },
                            {
                                name = 'observations',
                                description = 'Associated observations',
                                type = 'array',
                                required = true,
                                items = {
                                    name = 'value',
                                    type = 'string',
                                    required = true,
                                },
                            },
                        },
                    },
                },
            },
        },
        returns = {
            {
                name = 'created_entities',
                description = 'List of successfully created entities',
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
            local entities = params.entities

            if not entities or type(entities) ~= 'table' then
                wrap_schedule(on_complete, {
                    error = 'entities parameter is required and must be a table',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('🧠 Creating ' .. #entities .. ' entities in memory...')

                memory_client:call_tool('create_entities', {
                    entities = entities,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to create entities: ' .. (error.message or 'unknown error'),
                        })
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

                    on_log('✅ Entities created successfully')

                    wrap_schedule(on_complete, {
                        created_entities = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for creating relations
function M.create_relations_tool()
    return {
        name = 'memory_create_relations',
        description = 'Create multiple new relations between entities in the knowledge graph.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'relations',
                    description = 'Array of relations to create. Each relation should have from, to, and relationType fields.',
                    type = 'array',
                    required = true,
                    items = {
                        name = 'requestObj',
                        description = 'Item array',
                        type = 'object',
                        fields = {
                            {
                                name = 'from',
                                description = 'Source entity name',
                                type = 'string',
                                required = true,
                            },
                            {
                                name = 'to',
                                description = 'Target entity name',
                                type = 'string',
                                required = true,
                            },
                            {
                                name = 'relationType',
                                description = 'Relationship type in active voice',
                                type = 'string',
                                required = true,
                            },
                        },
                    },
                },
            },
        },
        returns = {
            {
                name = 'created_relations',
                description = 'List of successfully created relations',
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
            local relations = params.relations

            if not relations or type(relations) ~= 'table' then
                wrap_schedule(on_complete, {
                    error = 'relations parameter is required and must be a table',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('🔗 Creating ' .. #relations .. ' relations in memory...')

                memory_client:call_tool('create_relations', {
                    relations = relations,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to create relations: ' .. (error.message or 'unknown error'),
                        })
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

                    on_log('✅ Relations created successfully')

                    wrap_schedule(on_complete, {
                        created_relations = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for adding observations
function M.add_observations_tool()
    return {
        name = 'memory_add_observations',
        description = 'Add new observations to existing entities in the knowledge graph.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'observations',
                    description = 'Array of observations to add. Each should have entityName and contents fields.',
                    type = 'array',
                    required = true,
                    items = {
                        name = 'requestObj',
                        description = 'Item array',
                        type = 'object',
                        fields = {
                            {
                                name = 'entityName',
                                description = 'Target entity',
                                type = 'string',
                                required = true,
                            },
                            {
                                name = 'contents',
                                description = 'With new observations to add',
                                type = 'array',
                                required = true,
                                items = {
                                    name = 'value',
                                    type = 'string',
                                    required = true,
                                },
                            },
                        },
                    },
                },
            },
        },
        returns = {
            {
                name = 'added_observations',
                description = 'List of successfully added observations',
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
            local observations = params.observations

            if not observations or type(observations) ~= 'table' then
                wrap_schedule(on_complete, {
                    error = 'observations parameter is required and must be a table',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('📝 Adding observations to memory...')

                memory_client:call_tool('add_observations', {
                    observations = observations,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to add observations: ' .. (error.message or 'unknown error'),
                        })
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

                    on_log('✅ Observations added successfully')

                    wrap_schedule(on_complete, {
                        added_observations = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for searching nodes
function M.search_nodes_tool()
    return {
        name = 'memory_search_nodes',
        description = 'Search for nodes in the knowledge graph based on a query. Searches across entity names, types, and observation content.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'query',
                    description = 'Search query string to find matching nodes',
                    type = 'string',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'search_results',
                description = 'Matching entities and their relations',
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
                wrap_schedule(on_complete, {
                    error = 'query parameter is required',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('🔍 Searching memory for: ' .. query)

                memory_client:call_tool('search_nodes', {
                    query = query,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to search nodes: ' .. (error.message or 'unknown error'),
                        })
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

                    wrap_schedule(on_complete, {
                        search_results = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for reading the entire graph
function M.read_graph_tool()
    return {
        name = 'memory_read_graph',
        description = 'Read the entire knowledge graph with all entities and relations.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'placeholder',
                    description = "Avante doesn't support empty inputs/objects so this is here. Fill with anything",
                    type = 'boolean',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'graph_data',
                description = 'Complete knowledge graph structure',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the operation failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(_, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('📖 Reading entire knowledge graph...')

                memory_client:call_tool('read_graph', nil, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to read graph: ' .. (error.message or 'unknown error'),
                        })
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

                    on_log('✅ Graph read successfully')

                    wrap_schedule(on_complete, {
                        graph_data = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for opening specific nodes
function M.open_nodes_tool()
    return {
        name = 'memory_open_nodes',
        description = 'Retrieve specific nodes by name from the knowledge graph.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'names',
                    description = 'Entity names to retrieve',
                    type = 'array',
                    required = true,
                    items = {
                        name = 'value',
                        type = 'string',
                        required = true,
                    },
                },
            },
        },
        returns = {
            {
                name = 'nodes_data',
                description = 'Requested entities and their relations',
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
            local names = params.names

            if not names or type(names) ~= 'table' then
                wrap_schedule(on_complete, {
                    error = 'names parameter is required and must be a table',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('🎯 Opening nodes: ' .. table.concat(names, ', '))

                memory_client:call_tool('open_nodes', {
                    names = names,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to open nodes: ' .. (error.message or 'unknown error'),
                        })
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

                    on_log('✅ Nodes opened successfully')

                    wrap_schedule(on_complete, {
                        nodes_data = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for deleting entities
function M.delete_entities_tool()
    return {
        name = 'memory_delete_entities',
        description = 'Remove entities and their relations from the knowledge graph.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'entity_names',
                    description = 'Entity names to delete',
                    type = 'array',
                    required = true,
                    items = {
                        name = 'value',
                        type = 'string',
                        required = true,
                    },
                },
            },
        },
        returns = {
            {
                name = 'deletion_result',
                description = 'Result of the deletion operation',
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
            local entity_names = params.entity_names

            if not entity_names or type(entity_names) ~= 'table' then
                wrap_schedule(on_complete, {
                    error = 'entity_names parameter is required and must be a table',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('🗑️ Deleting entities: ' .. table.concat(entity_names, ', '))

                memory_client:call_tool('delete_entities', {
                    entityNames = entity_names,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to delete entities: ' .. (error.message or 'unknown error'),
                        })
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

                    on_log('✅ Entities deleted successfully')

                    wrap_schedule(on_complete, {
                        deletion_result = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for deleting observations
function M.delete_observations_tool()
    return {
        name = 'memory_delete_observations',
        description = 'Remove specific observations from entities in the knowledge graph.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'deletions',
                    description = 'Array of deletions. Each should have entityName and observations fields.',
                    type = 'array',
                    required = true,
                    items = {
                        name = 'requestObj',
                        description = 'Item array',
                        type = 'object',
                        fields = {
                            {
                                name = 'entityName',
                                description = 'Target entity',
                                type = 'string',
                                required = true,
                            },
                            {
                                name = 'observations',
                                description = 'Array string with observations to remove',
                                type = 'array',
                                required = true,
                                items = {
                                    name = 'value',
                                    type = 'string',
                                    required = true,
                                },
                            },
                        },
                    },
                },
            },
        },
        returns = {
            {
                name = 'deletion_result',
                description = 'Result of the deletion operation',
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
            local deletions = params.deletions

            if not deletions or type(deletions) ~= 'table' then
                wrap_schedule(on_complete, {
                    error = 'deletions parameter is required and must be a table',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('🗑️ Deleting observations from memory...')

                memory_client:call_tool('delete_observations', {
                    deletions = deletions,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to delete observations: ' .. (error.message or 'unknown error'),
                        })
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

                    on_log('✅ Observations deleted successfully')

                    wrap_schedule(on_complete, {
                        deletion_result = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Avante tool for deleting relations
function M.delete_relations_tool()
    return {
        name = 'memory_delete_relations',
        description = 'Remove specific relations from the knowledge graph.',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'relations',
                    description = 'Array of relations to delete. Each should have from, to, and relationType fields.',
                    type = 'array',
                    required = true,
                    items = {
                        name = 'requestObj',
                        description = 'Item array',
                        type = 'object',
                        fields = {
                            {
                                name = 'from',
                                description = 'Source entity name',
                                type = 'string',
                                required = true,
                            },
                            {
                                name = 'to',
                                description = 'Target entity name',
                                type = 'string',
                                required = true,
                            },
                            {
                                name = 'relationType',
                                description = 'Relationship type',
                                type = 'string',
                                required = true,
                            },
                        },
                    },
                },
            },
        },
        returns = {
            {
                name = 'deletion_result',
                description = 'Result of the deletion operation',
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
            local relations = params.relations

            if not relations or type(relations) ~= 'table' then
                wrap_schedule(on_complete, {
                    error = 'relations parameter is required and must be a table',
                })
                return
            end

            if not ensure_client() then
                wrap_schedule(on_complete, {
                    error = 'Failed to initialize Memory MCP client',
                })
                return
            end

            local function wait_and_execute()
                if not client_ready then
                    vim.defer_fn(wait_and_execute, 100)
                    return
                end

                on_log('🗑️ Deleting relations from memory...')

                memory_client:call_tool('delete_relations', {
                    relations = relations,
                }, function(result, error)
                    if error then
                        wrap_schedule(on_complete, {
                            error = 'Failed to delete relations: ' .. (error.message or 'unknown error'),
                        })
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

                    on_log('✅ Relations deleted successfully')

                    wrap_schedule(on_complete, {
                        deletion_result = response,
                    })
                end)
            end

            wait_and_execute()
        end,
    }
end

-- Cleanup function
function M.cleanup()
    if memory_client then
        memory_client:stop()
        memory_client = nil
        client_ready = false
    end
end

return M
