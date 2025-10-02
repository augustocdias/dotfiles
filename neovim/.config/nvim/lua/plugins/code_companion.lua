return {
    'olimorris/codecompanion.nvim',
    event = 'VeryLazy',
    cmd = {
        'CodeCompanion',
        'CodeCompanionChat',
        'CodeCompanionActions',
        'CodeCompanionCmd',
        'CodeCompanionHistory',
        'CodeCompanionSummaries',
    },
    opts = {
        system_prompt = require('utils.ai.prompt').system_prompt(),
        strategies = {
            chat = {
                adapter = 'anthropic',
                tools = {
                    opts = {
                        auto_submit_errors = true,
                        default_tools = {
                            'file_search',
                            'get_changed_files',
                            'grep_search',
                            'read_file',
                            'cmd_runner',
                            'fetch_webpage',
                            'search_web',
                            'list_code_usages',
                        },
                    },
                },
                keymaps = {
                    close = {
                        modes = { n = { '<C-c>', 'q' }, i = '<C-c>' },
                        opts = {},
                    },
                },
            },
            inline = {
                adapter = 'anthropic',
            },
            cmd = {
                adapter = 'anthropic',
            },
        },
        adapters = {
            http = {
                anthropic = function()
                    return require('codecompanion.adapters').extend('anthropic', {
                        formatted_name = 'Anthropic Claude Sonnet 4.5',
                        headers = {
                            ['anthropic-beta'] = 'context-1m-2025-08-07',
                        },
                        schema = {
                            model = {
                                default = 'claude-sonnet-4-5-20250929',
                            },
                            choices = {
                                ['claude-sonnet-4-5-20250929'] = {
                                    nice_name = 'Claude Sonnet 4.5',
                                    opts = { can_reason = true, has_vision = true },
                                },
                            },
                            thinking_budget = {
                                default = 63000,
                            },
                        },
                    })
                end,
            },
        },
        extensions = {
            mcphub = {
                callback = 'mcphub.extensions.codecompanion',
                opts = {
                    make_vars = true,
                    make_slash_commands = true,
                    show_result_in_chat = true,
                },
            },
            history = {
                enabled = true,
                opts = {
                    keymap = '<leader>ah',
                    save_chat_keymap = '<leader>as',
                    auto_save = true,
                    -- Number of days after which chats are automatically deleted (0 to disable)
                    expiration_days = 0,
                    picker = 'snacks',
                    picker_keymaps = {
                        rename = { n = 'r', i = '<M-r>' },
                        delete = { n = 'd', i = '<M-d>' },
                        duplicate = { n = '<C-y>', i = '<C-y>' },
                    },
                    auto_generate_title = true,
                    title_generation_opts = {
                        ---Number of user prompts after which to refresh the title (0 to disable)
                        refresh_every_n_prompts = 0,
                        max_refreshes = 3,
                    },
                    ---On exiting and entering neovim, loads the last chat on opening chat
                    continue_last_chat = true,
                    delete_on_clearing_chat = false,
                    dir_to_save = vim.fn.stdpath('data') .. '/codecompanion-history',
                    summary = {
                        create_summary_keymap = '<leader>am',
                        browse_summaries_keymap = '<leader>ay',

                        generation_opts = {
                            context_size = 1000000, -- max tokens that the model supports
                            include_references = true, -- include slash command content
                            include_tool_outputs = true, -- include tool execution results
                        },
                    },
                },
            },
        },
        display = {
            chat = {
                start_in_insert_mode = true,
                show_token_count = true,
                fold_context = true,
            },
        },
    },
    keys = {
        {
            '<leader>at',
            '<cmd>CodeCompanionChat Toggle<CR>',
            mode = { 'n' },
            desc = 'Toggle CodeCompanion Chat',
            noremap = true,
            silent = true,
        },
    },
    dependencies = {
        'nvim-lua/plenary.nvim',
        'ravitemer/codecompanion-history.nvim',
        {
            'ravitemer/mcphub.nvim',
            build = 'npm install -g mcp-hub@latest',
            config = true,
        },
    },
}
