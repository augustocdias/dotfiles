-- note taking

return {
    'nvim-neorg/neorg',
    ft = 'norg',
    build = ':Neorg sync-parsers',
    dependencies = {
        'nvim-neotest/nvim-nio',
        'nvim-neorg/lua-utils.nvim',
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'pysan3/pathlib.nvim',
        'benlubas/neorg-interim-ls',
    },
    opts = {
        load = {
            ['core.defaults'] = {},
            ['core.completion'] = {
                config = {
                    engine = { module_name = 'external.lsp-completion' },
                },
            },
            ['core.concealer'] = {},
            ['core.dirman'] = {
                config = {
                    workspaces = {
                        vim.fn.expand('~/Library/Mobile Documents/com~apple~CloudDocs/Documents/notes'),
                    },
                },
            },
            ['core.export'] = {},
            ['core.export.markdown'] = {},
            ['core.summary'] = {},
            ['core.text-objects'] = {},
            ['core.integrations.treesitter'] = {},
            ['core.neorgcmd.commands.return'] = {},
            ['external.interim-ls'] = {
                config = {
                    -- default config shown
                    completion_provider = {
                        -- Enable or disable the completion provider
                        enable = true,

                        -- Show file contents as documentation when you complete a file name
                        documentation = true,

                        -- Try to complete categories provided by Neorg Query. Requires `benlubas/neorg-query`
                        categories = false,

                        people = {
                            enable = false,
                            path = 'people',
                        },
                    },
                },
            },
        },
    },
    keys = {
        {
            '<M-n>',
            function()
                require('setup.neorg').open_workspace_notes()
            end,
            mode = { 'n' },
            description = 'Open Notes for Current Project',
            noremap = true,
        },
    },
}
