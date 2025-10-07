local logger = require('utils.logger').new('ollama')
local M = {}

function M:new(models)
    self.models = models or { 'llama3', 'nomic-embed-text' }
end

function M:is_ollama_running(cb)
    local sock = vim.uv.new_tcp()
    sock:connect('127.0.0.1', 11434, function(err)
        sock:close()
        cb(not err)
    end)
end

function M:start_serve()
    vim.schedule(function()
        vim.notify("Starting 'ollama serve' in background...", vim.log.levels.INFO, { title = 'avante.nvim' })
        logger.info("Starting 'ollama serve' in background...")
        local serve = vim.system({
            'sh',
            '-c',
            'nohup ollama serve >> ' .. vim.fn.stdpath('cache') .. '/avante_ollama.log 2>&1 &',
        }, {
            detach = true,
            text = true,
            on_stdout = function(_, data)
                if data then
                    logger.info('[ollama] ' .. table.concat(data, '\n'))
                end
            end,
            on_stderr = function(_, data)
                if data then
                    logger.info('[ollama error] ' .. table.concat(data, '\n'))
                end
            end,
        })
        serve:wait()
    end)
end

function M:download_ollama_models()
    -- 1. Check if ollama is installed
    if vim.fn.executable('ollama') == 0 then
        vim.notify("'ollama' not found in PATH. Please install ollama", vim.log.levels.ERROR, { title = 'ai.nvim' })
        return
    end

    -- 3. Start or inform about ollama serve
    self:is_ollama_running(function(running)
        if not running then
            self:start_serve()
        else
            logger.info("'ollama serve' already running.")
        end

        -- 4. Pull models if missing
        for _, model in ipairs(self.models) do
            vim.schedule(function()
                vim.fn.system("ollama list | grep '^" .. model .. "'")
                if vim.v.shell_error ~= 0 then
                    vim.schedule(function()
                        vim.notify('ℹ️ Pulling Ollama model: ' .. model, vim.log.levels.INFO, { title = 'ai.nvim' })
                    end)
                    logger.info('Pulling model: ' .. model)
                    vim.fn.jobstart({ 'ollama', 'pull', model }, {
                        stdout_buffered = true,
                        stderr_buffered = true,
                        on_stdout = vim.schedule_wrap(function(_, data)
                            if data then
                                logger.info('[ollama] ' .. table.concat(data, '\n'))
                            end
                        end),
                        on_stderr = vim.schedule_wrap(function(_, data)
                            if data then
                                logger.info('[ollama error] ' .. table.concat(data, '\n'))
                            end
                        end),
                    })
                else
                    logger.info('Model already present: ' .. model)
                end
            end)
        end
    end)
end

return M
