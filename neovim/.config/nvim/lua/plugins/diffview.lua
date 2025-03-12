-- creates a tab focd on diff view and git history

return {
    'sindrets/diffview.nvim',
    enabled = not vim.g.vscode,
    cmd = {
        'DiffviewOpen',
        'DiffviewRefresh',
        'DiffviewFocusFiles',
        'DiffviewFileHistory',
        'DiffviewToggleFiles',
    },
    config = true,
    keys = {
        {
            '<leader>gd',
            ':DiffviewOpen<CR>',
            mode = { 'n' },
            desc = 'Open Diff View',
            noremap = true,
        },
        {
            '<leader>ge',
            ':DiffviewFocusFiles<CR>',
            mode = { 'n' },
            desc = 'Diff View Focus Files',
            noremap = true,
        },
        {
            '<leader>gh',
            ':DiffviewFileHistory<CR>',
            mode = { 'n' },
            desc = 'Diff View File History',
            noremap = true,
        },
        {
            '<leader>gr',
            ':DiffviewRefresh<CR>',
            mode = { 'n' },
            desc = 'Diff View Refresh',
            noremap = true,
        },
        {
            '<leader>gx',
            ':DiffviewClose<CR>',
            mode = { 'n' },
            desc = 'Close Diff View',
            noremap = true,
        },
    },
}
