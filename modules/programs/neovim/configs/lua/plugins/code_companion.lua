return {
    {
        'codecompanion-spinner',
        dep_of = 'codecompanion',
    },
    {
        'codecompanion-history',
        dep_of = 'codecompanion',
    },
    {
        'codecompanion',
        cmd = {
            'CodeCompanion',
            'CodeCompanionChat',
            'CodeCompanionActions',
            'CodeCompanionCmd',
            'CodeCompanionHistory',
            'CodeCompanionSummaries',
        },
        keys = {
            {
                '<leader>at',
                '<cmd>CodeCompanionChat Toggle<CR>',
                desc = 'Toggle CodeCompanion Chat',
                noremap = true,
                silent = true,
            },
        },
        after = function()
            require('codecompanion').setup({
                opts = {
                    log_level = 'DEBUG',
                },
                interactions = {
                    chat = {
                        opts = {
                            system_prompt = require('utils.ai').system_prompt(),
                        },
                        adapter = 'opencode',
                        tools = {
                            ['file_search'] = {
                                opts = {
                                    require_cmd_approval = false,
                                    require_approval_before = false,
                                },
                            },
                            ['memory'] = {
                                opts = {
                                    require_cmd_approval = false,
                                    require_approval_before = false,
                                },
                            },
                            ['read_file'] = {
                                opts = {
                                    require_cmd_approval = false,
                                    require_approval_before = false,
                                },
                            },
                            ['grep_search'] = {
                                opts = {
                                    require_cmd_approval = false,
                                    require_approval_before = false,
                                },
                            },
                            opts = {
                                system_prompt = {
                                    enabled = true,
                                    replace_main_system_prompt = false,
                                },
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
                    },
                    inline = {
                        adapter = 'anthropic',
                    },
                    cmd = {
                        adapter = 'anthropic',
                    },
                },
                rules = {
                    skills = {
                        description = 'LLM Skills',
                        enabled = function()
                            local Path = require('plenary.path')
                            return Path:new(vim.fn.getcwd() .. '/.claude/skills'):exists()
                        end,
                        files = {
                            {
                                path = vim.fn.getcwd() .. '/.claude/skills',
                                files = '*.md',
                            },
                        },
                    },
                },
                adapters = {
                    acp = {
                        opencode = function()
                            return require('codecompanion.adapters').extend('opencode', {
                                defaults = {
                                    mode = 'plan',
                                },
                            })
                        end,
                    },
                    http = {
                        anthropic = function()
                            return require('codecompanion.adapters').extend('anthropic', {
                                headers = {
                                    ['anthropic-beta'] = 'context-1m-2025-08-07',
                                },
                                schema = {
                                    model = {
                                        default = 'claude-opus-4-6',
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
                                adapter = 'anthropic',
                                ---Number of user prompts after which to refresh the title (0 to disable)
                                refresh_every_n_prompts = 0,
                                max_refreshes = 3,
                            },
                            ---On exiting and entering neovim, loads the last chat on opening chat
                            continue_last_chat = false,
                            delete_on_clearing_chat = false,
                            dir_to_save = vim.fn.stdpath('data') .. '/codecompanion-history',
                            chat_filter = function(chat_data)
                                return chat_data.cwd == vim.fn.getcwd()
                            end,
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
                    spinner = {},
                },
                display = {
                    chat = {
                        start_in_insert_mode = true,
                        show_token_count = true,
                        fold_context = true,
                        window = {
                            position = 'right',
                            width = 0.3,
                            sticky = true,
                        },
                    },
                },
            })
        end,
    },
}
