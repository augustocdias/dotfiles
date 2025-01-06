return {
    setup = function()
        require('neorg').setup({
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
                            vim.fn.expand('~/Documents/notes'),
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
        })
    end,
    open_workspace_notes = function()
        local notes_location = vim.fn.expand('~/Documents/notes/projects/')
        local note_name = vim.fn.getcwd():match('([^\\/]*)$')
        vim.cmd('e ' .. notes_location .. note_name .. '.norg')
    end,
}
