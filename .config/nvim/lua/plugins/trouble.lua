-- adds a bottom panel with lsp diagnostics, quickfixes, etc.

return {
    'folke/trouble.nvim',
    enabled = not vim.g.vscode,
    opts = {
        modes = {
            diagnostics = {
                filter = {
                    any = {
                        function(item)
                            return item.filename:find((vim.loop or vim.uv).cwd(), 1, true)
                        end,
                    },
                },
            },
        },
    },
    keys = {
        {
            '<M-t>',
            ':Trouble diagnostics toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Show diagnostics pane',
            noremap = true,
            silent = true,
        },
        {
            '<F1>',
            ':Trouble todo toggle<CR>',
            mode = { 'n' },
            desc = 'Toggle todo list',
            noremap = true,
        },
    },
}
