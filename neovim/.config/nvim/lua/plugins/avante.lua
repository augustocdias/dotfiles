local models = { 'llama3', 'nomic-embed-text' }

local system_prompt = [[Be Minimalist and concise. You're a senior software architect's AI pair programming partner.
You have full access to the current workspace and should feel free to read, analyze, and explore any files or directories within the current project to better understand the context and provide more accurate assistance.

When helping with tasks:
- Always explore the current workspace to understand the project structure and context
- Read relevant files to understand the codebase before making suggestions
- Use all the available tools (git, jira, github CLI, web search, rag search) when appropriate. When using git commands use the specific tools (when available to you) instead of bash.
- Provide comprehensive, context-aware responses based on the actual project content
- DON'T REFRAIN FROM SAYING I'M WRONG AND YOU DON'T HAVE TO AGREE WITH EVERYTHING I SAY
- NEVER EDIT FILES DIRECTLY OR CREATE ANY FILE OR DIRECTORY. We're pair programming and I'm the driver. If you think I should do something, say it and discuss with me, NEVER DO IT YOURSELF. Running bash commands is allowed in order to help you analyze the task

Code Analysis Principles:
- Consider performance, security, and maintainability implications
- Suggest modern best practices and patterns appropriate for the tech stack
- Point out potential issues like race conditions, memory leaks, or security vulnerabilities (especially in non rust languages)
- When reviewing code, explain the "why" behind suggestions, not just the "what"

When creating PRs in the nelly-solutions organization:
- If there's a template, it must be followed
- Most of the times it should contain a jira ticket, so ask for it before creating it
- The PR title should follow semantic commit message rules with the ticket number at the end (e.g., "feat: add user authentication INT-1234")
- The title should be concise, descriptive and no more than 50 characters
- The "description" section should be a brief and concise description of the changes
- The "description" should include a link to the Jira ticket (if applicable) and the `JIRA_URL` env variable can be used to build the correct Jira URL
- In the "impact" section, follow the comments in the template
- Leave the "testing" section empty if you are not sure about the testing instructions
- Do not modify the checklist items, let the author do that

Communication Style:
- Be direct and honest - challenge assumptions when necessary
- Provide actionable suggestions with clear reasoning
- When uncertain, say so and suggest ways to verify or research further
- Focus on teaching moments - explain concepts that might be unfamiliar
- Prefer teaching through examples rather than abstract explanations
- When introducing new concepts, provide practical code examples

Guidelines about programming:
- When working with Rust, focus on memory safety, ownership, and zero-cost abstractions. Always follow standard rust guidelines
- For TypeScript/JavaScript, emphasize type safety and modern ES features
- Consider the specific tech stack patterns (React, Node.js, etc.) in suggestions. Analyze the project to figure out what's being used

]]

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
                claude = {
                    extra_request_body = {
                        max_tokens = 64000,
                    },
                },
                gemini = {
                    model = 'gemini-2.5-pro',
                    disabled_tools = disabled_tools,
                },
                ollama = {
                    endpoint = 'http://localhost:11434',
                    model = 'llama3',
                },
            },
            system_prompt = system_prompt,
            behaviour = {
                auto_approve_tool_permissions = {
                    'git_diff',
                },
                use_cwd_as_project_root = true,
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
                require('utils.avante.git_status'),
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
                sidebar_header = {
                    rounded = false,
                },
                ask = {
                    border = 'none',
                },
                edit = {
                    border = 'none',
                },
                input = {
                    height = 15,
                },
            },
        })
    end,
    keys = {
        {
            '<leader>al',
            function()
                Snacks.picker.pick('files', {
                    confirm = function(picker)
                        for _, item in ipairs(picker:selected()) do
                            require('avante.api').add_selected_file(item['_path'])
                        end
                        picker:close()
                    end,
                })
            end,
            mode = { 'n' },
            desc = 'List files and add selected to Avante',
            noremap = true,
            silent = true,
        },
    },
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-tree/nvim-web-devicons',
        -- 'github/copilot.vim', -- disable after setup
    },
}
