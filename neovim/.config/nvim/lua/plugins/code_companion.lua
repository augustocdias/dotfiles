local gh_tool = require('ai.cc.tools.gh')
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
        opts = {
            log_level = 'DEBUG',
        },
        system_prompt = require('ai.prompt').system_prompt(),
        -- memory = { opts = { chat = { enabled = true } } },
        strategies = {
            chat = {
                opts = {
                    system_prompt = require('ai.prompt').system_prompt(),
                },
                adapter = 'anthropic',
                tools = {
                    ['activitywatch'] = {
                        callback = 'ai.cc.tools.activitywatch',
                        description = 'Query ActivityWatch data for productivity analytics and time tracking. Remember to always include neovim buckets when searching',
                    },
                    ['apple_mail'] = {
                        callback = 'ai.cc.tools.apple_mail',
                        description = 'Fetch unread emails from Apple Mail',
                    },
                    ['apple_script'] = {
                        callback = 'ai.cc.tools.apple_script',
                        description = 'Execute AppleScript code on macOS',
                        opts = {
                            requires_approval = true,
                        },
                    },
                    ['calendar_scheduler'] = {
                        callback = 'ai.cc.tools.calendar_scheduler',
                        description = 'Fetch calendar appointments and manage meeting URL scheduling via Hammerspoon. Never filter out possible duplicates',
                    },
                    ['datadog'] = {
                        callback = 'ai.cc.tools.datadog',
                        description = 'Interact with Datadog API for logs, metrics, events, and monitoring data to help troubleshoot production issues',
                    },
                    ['date'] = {
                        callback = 'ai.cc.tools.date',
                        description = 'Get current date or make date operations',
                    },
                    ['gh_issue'] = {
                        callback = gh_tool.gh_issue,
                        description = 'GitHub Issue operations (create, list, view, close, reopen)',
                        opts = {
                            requires_approval = {},
                        },
                    },
                    ['gh_pr'] = {
                        callback = gh_tool.gh_pr,
                        description = 'GitHub Pull Request operations (create, list, view, merge, close, reopen, ready, draft)',
                        opts = {
                            requires_approval = {},
                        },
                    },
                    ['gh_repo'] = {
                        callback = gh_tool.gh_repo,
                        description = 'GitHub Repository operations (view, list, create, clone, fork)',
                        opts = {
                            requires_approval = {},
                        },
                    },
                    ['gh_run'] = {
                        callback = gh_tool.gh_run,
                        description = 'GitHub Actions run operations (list, view, cancel, rerun)',
                        opts = {
                            requires_approval = {},
                        },
                    },
                    ['gh_search'] = {
                        callback = gh_tool.gh_search,
                        description = 'GitHub search operations (repos, issues, prs, code)',
                        opts = {
                            requires_approval = {},
                        },
                    },
                    ['gh_status'] = {
                        callback = gh_tool.gh_status,
                        description = 'GitHub repository and user status operations',
                        opts = {
                            requires_approval = {},
                        },
                    },
                    ['gh_workflow'] = {
                        callback = gh_tool.gh_workflow,
                        description = 'GitHub Actions workflow operations (list, view, run)',
                        opts = {
                            requires_approval = {},
                        },
                    },
                    ['git'] = {
                        callback = 'ai.cc.tools.git',
                        description = 'Git command line tool',
                        opts = {
                            requires_approval = {}, -- if not a boolean will call prompt_condition
                        },
                    },
                    ['google_calendar'] = {
                        callback = 'ai.cc.tools.google_calendar',
                        description = 'Query events and details from Google Calendar using gcalcli',
                    },
                    ['jira'] = {
                        callback = 'ai.cc.tools.jira',
                        description = 'Interact with Atlassian Jira API for ticket management, transitions, and comments',
                        opts = {
                            requires_approval = {},
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
                            'mcp',
                            -- custom
                            'activitywatch',
                            'apple_mail',
                            'apple_script',
                            'calendar_scheduler',
                            'datadog',
                            'date',
                            'gh',
                            'git',
                            'gh_issue',
                            'gh_pr',
                            'gh_repo',
                            'gh_run',
                            'gh_search',
                            'gh_status',
                            'gh_workflow',
                            'google_calendar',
                            'jira',
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
                    make_tools = true,
                    show_server_tools_in_chat = true,
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
        'franco-ruggeri/codecompanion-spinner.nvim',
        'ravitemer/codecompanion-history.nvim',
        {
            'ravitemer/mcphub.nvim',
            build = 'npm install -g mcp-hub@latest',
            config = true,
        },
    },
}
