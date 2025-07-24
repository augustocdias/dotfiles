local models = { 'llama3', 'nomic-embed-text' }

local function log(msg)
    local logfile = vim.fn.stdpath('cache') .. '/avante_ollama.log'
    local f = io.open(logfile, 'a')
    if f then
        f:write(os.date('[%Y-%m-%d %H:%M:%S] ') .. msg .. '\n')
        f:close()
    end
end

local function is_ollama_running(cb)
    local sock = vim.uv.new_tcp()
    sock:connect('127.0.0.1', 11434, function(err)
        sock:close()
        cb(not err)
    end)
end

local function start_serve()
    vim.schedule(function()
        vim.notify("Starting 'ollama serve' in background...", vim.log.levels.INFO, { title = 'avante.nvim' })
        log("Starting 'ollama serve' in background...")
        local serve = vim.system({
            'sh',
            '-c',
            'nohup ollama serve >> ' .. vim.fn.stdpath('cache') .. '/avante_ollama.log 2>&1 &',
        }, {
            detach = true,
            text = true,
            on_stdout = function(_, data)
                if data then
                    log('[ollama] ' .. table.concat(data, '\n'))
                end
            end,
            on_stderr = function(_, data)
                if data then
                    log('[ollama error] ' .. table.concat(data, '\n'))
                end
            end,
        })
        serve:wait()
    end)
end

local function download_ollama_models()
    -- 1. Check if ollama is installed
    if vim.fn.executable('ollama') == 0 then
        vim.notify(
            "'ollama' not found in PATH. Please install ollama to use RAG.",
            vim.log.levels.ERROR,
            { title = 'avante.nvim' }
        )
        return
    end

    -- 3. Start or inform about ollama serve
    is_ollama_running(function(running)
        if not running then
            start_serve()
        else
            log("'ollama serve' already running.")
        end

        -- 4. Pull models if missing
        for _, model in ipairs(models) do
            vim.schedule(function()
                vim.fn.system("ollama list | grep '^" .. model .. "'")
                if vim.v.shell_error ~= 0 then
                    vim.schedule(function()
                        vim.notify(
                            'ℹ️ Pulling Ollama model: ' .. model,
                            vim.log.levels.INFO,
                            { title = 'avante.nvim' }
                        )
                    end)
                    log('Pulling model: ' .. model)
                    vim.fn.jobstart({ 'ollama', 'pull', model }, {
                        stdout_buffered = true,
                        stderr_buffered = true,
                        on_stdout = vim.schedule_wrap(function(_, data)
                            if data then
                                log('[ollama] ' .. table.concat(data, '\n'))
                            end
                        end),
                        on_stderr = vim.schedule_wrap(function(_, data)
                            if data then
                                log('[ollama error] ' .. table.concat(data, '\n'))
                            end
                        end),
                    })
                else
                    log('Model already present: ' .. model)
                end
            end)
        end
    end)
end

return {
    'yetone/avante.nvim',
    build = function()
        download_ollama_models()
        if vim.fn.has('win32') == 1 then
            return 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
        else
            return 'make'
        end
    end,
    event = 'VeryLazy',
    version = false,
    cmd = {
        'AvanteAsk',
        'AvanteChat',
        'AvanteBuild',
        'AvanteChatNew',
        'AvanteHistory',
        'AvanteClear',
        'AvanteEdit',
        'AvanteFocus',
        'AvanteRefresh',
        'AvanteStop',
        'AvanteSwitchProvider',
        'AvanteShowRepoMap',
        'AvanteToggle',
        'AvanteModels',
        'AvanteSwitchSelectorProvider',
    },
    config = function()
        is_ollama_running(function(running)
            if not running then
                start_serve()
            else
                log("'ollama serve' already running.")
            end
        end)
        require('avante').setup({
            provider = 'gemini',
            providers = {
                gemini = {
                    model = 'gemini-2.5-pro',
                },
            },
            auto_suggestions_provider = nil,
            web_search_engine = {
                provider = 'searxng',
            },
            rag_service = {
                enabled = true,
                host_mount = os.getenv('HOME') .. '/dev',
                llm = {
                    provider = 'ollama',
                    endpoint = 'http://host.docker.internal:11434',
                    api_key = '',
                    model = 'llama3',
                    extra = nil,
                },
                embed = {
                    provider = 'ollama',
                    endpoint = 'http://host.docker.internal:11434',
                    api_key = '',
                    model = 'nomic-embed-text',
                    extra = {
                        embed_batch_size = 10,
                    },
                },
            },
        })
    end,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-tree/nvim-web-devicons',
        -- 'github/copilot.vim', -- disable after setup
    },
}
