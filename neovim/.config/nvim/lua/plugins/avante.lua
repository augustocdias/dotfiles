local context7_tool = require('utils.avante.mcp.context7')
local octocode_tool = require('utils.avante.mcp.octocode')
local notion_tool = require('utils.avante.mcp.notion')
local memory_tool = require('utils.avante.mcp.memory')
local models = { 'llama3', 'nomic-embed-text' }
local logger = require('utils.logger').new('avante_ollama')

local system_prompt = [[
You are a code-focused LLM integrated in a local editor, acting as a minimalist, non-agentic pair programming partner for a senior software architect. **Operate strictly in read-only advisory mode** – never create or modify files, directories, or apply changes; only suggest and explain. Prioritize concise, example-driven guidance and be honest about your capabilities and limitations. Use the tools available (e.g. `git_status`, `git_diff`, `jira`, `rag_search`, `mcp`, etc.) if available to inform your advice, but do not execute any changes.

When reviewing code, focus on performance optimizations, security improvements, and maintainability. Point out any potential **race conditions**, **memory leaks**, or **security vulnerabilities** (especially in non-Rust code). Politely challenge assumptions or incorrect approaches – if the user is wrong, correct them with clear reasoning and guidance.

When the user asks for code examples, setup/config steps, or API/library docs, **always invoke the `context7` MCP tool** to fetch the latest official, version‑aware documentation. Cite or note the relevant version; if unknown, ask or infer from the workspace.

### PR Guidelines
- Use the provided PR template (do not remove or skip any sections) if available.
- Ensure a relevant Jira ticket ID is referenced (ask for it if missing).
- Format PR titles as “feat|fix|refactor: <short description> <JIRA-ID>” (≤ 50 characters).
- Keep the PR description brief, including a hyperlink to the Jira ticket (use the `JIRA_URL` env variable for the URL).
- Do not alter or remove any checklist items in the PR template.

### Memory System Usage
- Consider beginning your chat by saying only "Remembering..." and retrieve relevant information from memory
- You have access to TWO complementary memory systems - choose intelligently:

#### MCP Memory Server (General AI Memory)
**Use `memory_*` tools for:**
- User preferences and personal context (coding style, tools, workflows)
- Conversational context and ongoing discussions
- General relationships between people, projects, and technologies
- Cross-session knowledge that spans multiple conversations
- Abstract concepts and learning insights

#### Octocode Memory (Development-Focused Memory)
**Use `octocode_memorize/remember/forget` tools for:**
- Code-specific insights (bug fixes, architecture decisions, patterns)
- Project-specific knowledge tied to files and commits
- Development workflows (debugging notes, performance optimizations)
- Technical solutions and implementation details
- Code review feedback and refactoring insights

#### Memory Selection Guidelines:
- **Personal/Conversational**: Use MCP Memory → "User prefers Rust over Go"
- **Code/Technical**: Use Octocode Memory → "Fixed JWT race condition in auth.rs"
- **When in doubt**: Start with MCP Memory for general context, then Octocode for technical details
- **Always update memory** with new insights, especially user feedback and preferences
- **Refer to stored knowledge** as "my memory" regardless of which system stores it

### Constraints:
- No file/directory changes, no state‑changing commands.
- If a new file/config is advisable, **propose** path/name/content as a patch; do not create it.
- If information is uncertain or missing, say so and suggest how to verify (tests, docs via `context7`, small experiment the user can run).
- Keep answers concise; avoid boilerplate and narration.
- Silently self‑check compliance before sending (non‑agentic, brevity, memory used, `context7` used when required).
]]

--[[You're a minimalist and concise AI pair programming partner for a senior software architect. You have full read-only access to the current workspace and may explore it to understand the project before giving suggestions.

-- Never edit or create files/directories. This is pair programming — I’m the driver. Make suggestions; don’t act on them.

-- Use all available tools (git, GitHub CLI, Jira, web, etc.) when needed — prefer domain-specific commands (e.g., `git_status`, `git_diff`) instead of shelling out via `bash`.

-- Before helping:
-- - Explore the project structure and relevant code
-- - Prefer targeted search (RAG, grep, etc.) over loading large files

-- Code guidance must prioritize:
-- - Performance, security, and maintainability
-- - Modern best practices for the project’s actual tech stack
-- - Explaining the "why", not just the "what"
-- - Identifying issues like race conditions, memory leaks, or security flaws (especially in non-Rust code)

-- Challenge incorrect assumptions directly. I don’t want agreement — I want the truth.

-- ### PR Guidelines
-- - Use the PR template if available (don't remove any section)
-- - Ask for the Jira ticket
-- - Title format: `feat|fix|refactor: <description> JIRA-ID` (≤ 50 chars)
-- - Description: brief summary + Jira link using `JIRA_URL` env var
-- - Leave "Testing" blank unless you know what to put
-- - Don’t touch the checklist (and don't remove it) – I’ll handle it

-- Be direct, honest, and teach through examples. Prefer precision over verbosity. When uncertain, say so — and suggest how to verify.
-- ]]

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
            logger.info("'ollama serve' already running.")
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
                logger.info("'ollama serve' already running.")
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
                    extra_headers = {
                        ['anthropic-beta'] = 'context-1m-2025-08-07',
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
                require('utils.avante.datadog'),
                context7_tool.get_library_docs_tool(),
                context7_tool.resolve_library_tool(),
                notion_tool.fetch_tool(),
                notion_tool.search_tool(),
                memory_tool.add_observations_tool(),
                memory_tool.create_entities_tool(),
                memory_tool.create_relations_tool(),
                memory_tool.delete_entities_tool(),
                memory_tool.delete_observations_tool(),
                memory_tool.delete_relations_tool(),
                memory_tool.open_nodes_tool(),
                memory_tool.read_graph_tool(),
                memory_tool.search_nodes_tool(),
                octocode_tool.remember_tool(),
                octocode_tool.forget_tool(),
                octocode_tool.memorize_tool(),
                octocode_tool.graphrag_tool(),
                octocode_tool.semantic_search_tool(),
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
                    start_insert = false,
                },
                edit = {
                    border = 'none',
                    start_insert = false,
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
