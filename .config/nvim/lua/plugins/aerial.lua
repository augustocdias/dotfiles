-- show symbol tree in the current buffer

return {
    'stevearc/aerial.nvim', -- check if https://github.com/hedyhli/outline.nvim can replace it
    enabled = not vim.g.vscode,
    cmd = {
        'AerialToggle',
        'AerialOpenAll',
        'AerialCloseAll',
        'AerialTreeSyncFolds',
        'AerialInfo',
    },
    opts = {
        layout = {
            width = 30,
            default_direction = 'prefer_right',
            placement = 'window',
        },
    },
    keys = {
        {
            '<leader>aa',
            ':AerialOpenAll<CR>',
            mode = { 'n' },
            desc = 'Open All',
            noremap = true,
        },
        {
            '<leader>ac',
            ':AerialCloseAll<CR>',
            mode = { 'n' },
            desc = 'Close All',
            noremap = true,
        },
        {
            '<leader>ai',
            ':AerialInfo<CR>',
            mode = { 'n' },
            desc = 'Info',
            noremap = true,
        },
        {
            '<leader>as',
            ':AerialTreeSyncFolds<CR>',
            mode = { 'n' },
            desc = 'Sync code folding',
            noremap = true,
        },
        {
            '<leader>at',
            ':AerialToggle<CR>',
            mode = { 'n' },
            desc = 'Toggle',
            noremap = true,
        },
    },
}
