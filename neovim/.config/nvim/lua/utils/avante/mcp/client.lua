local M = {}

local function json_encode(data)
    return vim.json.encode(data)
end

local function json_decode(data)
    local ok, result = pcall(vim.json.decode, data)
    if ok then
        return result
    else
        return nil
    end
end

-- MCP Client class
local MCPClient = {}
MCPClient.__index = MCPClient

function MCPClient.new(name, command)
    local self = setmetatable({}, MCPClient)
    self.name = name
    self.command = command
    self.job_id = nil
    self.request_id = 1
    self.pending_requests = {}
    self.capabilities = {}
    self.initialized = false
    self.logger = require('utils.logger').new('mcp_' .. (string.gsub(name, '%W', '_')))
    return self
end

function MCPClient:_send_message(message)
    if not self.job_handle then
        error('MCP server not started')
    end

    local json_msg = json_encode(message)
    self.job_handle:write({ json_msg })
end

function MCPClient:_handle_message(data)
    local message = json_decode(data)
    if not message then
        return
    end

    -- Handle response to our request
    if message.id and self.pending_requests[message.id] then
        local callback = self.pending_requests[message.id]
        self.pending_requests[message.id] = nil
        if callback then
            if message.error then
                callback(nil, message.error)
            else
                callback(message.result, nil)
            end
        end
    end
end

function MCPClient:start()
    if self.job_handle then
        return true
    end

    local buffer = ''
    self.job_handle = vim.system(self.command, {
        stdout = function(err, data)
            if err then
                self.logger.error('stdout error: ' .. err)
            end
            if data and data ~= '' then
                self.logger.debug('stdout: ' .. data)
                buffer = buffer .. data
                -- Check if we have complete JSON-RPC message
                if buffer:match('}\n?$') then
                    self:_handle_message(buffer)
                    buffer = ''
                end
            end
        end,
        stderr = function(err, data)
            if err then
                self.logger.error('stderr error: ' .. err)
            end
            if data and data ~= '' then
                -- Use the smart stderr logging that distinguishes between errors and regular output
                self.logger.stderr(data)
            end
        end,
        stdin = true,
        detach = false,
    }, function(_, code, _)
        if code ~= 0 then
            self.logger.error('Server exited with code: ' .. code)
        else
            self.logger.info('Server exited normally')
        end
        self.job_handle = nil
        self.initialized = false
    end)

    return self.job_handle ~= nil
end

function MCPClient:stop()
    if self.job_handle then
        self.job_handle:kill('TERM')
        self.job_handle = nil
        self.initialized = false
    end
end

function MCPClient:_make_request(method, params, callback)
    local id = self.request_id
    self.request_id = self.request_id + 1

    local message = {
        jsonrpc = '2.0',
        id = id,
        method = method,
        params = params or {},
    }

    self.pending_requests[id] = callback
    self:_send_message(message)

    return id
end

function MCPClient:initialize(callback)
    if self.initialized then
        if callback then
            callback(true, nil)
        end
        return
    end

    local client_info = {
        name = 'custom-mcp-client',
        version = '1.0.0',
    }

    self:_make_request('initialize', {
        protocolVersion = '2024-11-05',
        capabilities = {
            roots = { listChanged = false },
        },
        clientInfo = client_info,
    }, function(result, error)
        if error then
            if callback then
                callback(false, error)
            end
            return
        end

        self.capabilities = result.capabilities or {}
        self.initialized = true

        -- Send initialized notification
        self:_send_message({
            jsonrpc = '2.0',
            method = 'notifications/initialized',
        })

        if callback then
            callback(true, nil)
        end
    end)
end

function MCPClient:list_tools(callback)
    if not self.initialized then
        if callback then
            callback(nil, 'Client not initialized')
        end
        return
    end

    self:_make_request('tools/list', {}, callback)
end

function MCPClient:call_tool(name, arguments, callback)
    if not self.initialized then
        if callback then
            callback(nil, 'Client not initialized')
        end
        return
    end

    self:_make_request('tools/call', {
        name = name,
        arguments = arguments,
    }, callback)
end

M.MCPClient = MCPClient
return M
