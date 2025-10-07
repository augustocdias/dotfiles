local default_error_handler = function(self, tools, _, result)
    local chat = tools.chat
    if result and type(result) == 'table' and result[1] ~= '' then
        local output = string.format('**Error:**\n```\n%s\n```', result[1])
        return chat:add_tool_output(self, output)
    else
        return chat:add_tool_output(self, 'Unknown error')
    end
end

local default_success_handler = function(self, tools, _, result)
    local chat = tools.chat
    if result and type(result) == 'table' and result[1] ~= '' then
        local output = tostring(result[1])
        return chat:add_tool_output(self, output)
    else
        return chat:add_tool_output(self, 'Tool executed successfully without any output')
    end
end

local reject_reason = function(self, tools)
    local chat = tools.chat
    local reason = vim.fn.input('Reason?')
    return chat:add_tool_output(self, 'User rejected. Reason: ' .. reason, '')
end

return {
    create_tool = function(opts)
        if opts.prompt_condition then
            assert(opts.prompt and opts.prompt_condition, 'If prompt_condition is informed, prompt must be too')
        end

        return {
            name = opts.name,
            cmds = {
                opts.func,
            },
            schema = {
                type = 'function',
                ['function'] = {
                    name = opts.name,
                    description = opts.description,
                    strict = true,
                    parameters = {
                        type = 'object',
                        properties = opts.properties,
                        required = opts.required or {},
                        additionalProperties = false,
                    },
                },
            },
            system_prompt = opts.system_prompt or opts.description,
            handlers = {
                prompt_condition = opts.prompt_condition or nil,
            },
            output = {
                prompt = opts.prompt or nil,
                rejected = opts.rejected or reject_reason,
                error = opts.error or default_error_handler,
                success = opts.success or default_success_handler,
            },
        }
    end,
}
