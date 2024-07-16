return {
    setup = function()
        require('neorg').setup({
            load = {
                ['core.defaults'] = {},
                ['core.completion'] = {
                    config = {
                        engine = 'nvim-cmp',
                    },
                },
                ['core.integrations.nvim-cmp'] = {},
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
            },
        })
    end,
    open_workspace_notes = function()
        local notes_location = vim.fn.expand('~/Documents/notes/projects/')
        local note_name = vim.fn.getcwd():match('([^\\/]*)$')
        vim.cmd('e ' .. notes_location .. note_name .. '.norg')
    end,
}
