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

local disabled_tools = {
    'delete_path',
    'create_dir',
    'move_path',
    'copy_path',
    'create_file',
}

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
            mode = 'legacy',
            provider = 'claude',
            providers = {
                gemini = {
                    model = 'gemini-2.5-pro',
                    disabled_tools = disabled_tools,
                },
                ollama = {
                    endpoint = 'http://localhost:11434',
                    model = 'llama3',
                },
            },
            system_prompt = [[You have full access to the current workspace and should feel free to read, analyze, and explore any files or directories within the current project to better understand the context and provide more accurate assistance.
When helping with tasks:
- Always explore the current workspace to understand the project structure and context
- Read relevant files to understand the codebase before making suggestions
- Use the available tools (git, jira, github CLI, web search) when appropriate
- Provide comprehensive, context-aware responses based on the actual project content]],
            behaviour = {
                auto_approve_tool_permissions = {
                    'git_diff',
                },
            },
            selector = {
                provider = 'snacks',
            },
            input = {
                provider = 'snacks',
            },
            auto_suggestions_provider = nil,
            web_search_engine = {
                provider = 'google',
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
                        embed_batch_size = 5,
                    },
                },
            },
            custom_tools = {
                require('utils.avante.jira'),
                require('utils.avante.gh'),
            },
            disabled_tools = {
                'write_global_file',
                'create_dir',
                'delete_path',
                'move_path',
                'copy_path',
                'create_file',
                'write_to_file',
                'str_replace',
                'replace_in_file',
            },
            diff = {
                autojump = false,
            },
            windows = {
                ask = {
                    border = 'none',
                },
                edit = {
                    border = 'none',
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
