-- integrates focus on windows with zellij panes
return {
    'swaits/zellij-nav.nvim',
    lazy = true,
    event = 'VeryLazy',
    config = true,
    keys = {
        {
            '<C-h>',
            ':ZellijNavigateLeft<CR>',
            mode = { 'n' },
            desc = 'Focus on window to the left',
            noremap = true,
        },
        {
            '<C-l>',
            ':ZellijNavigateRight<CR>',
            mode = { 'n' },
            desc = 'Focus on window to the right',
            noremap = true,
        },
        {
            '<C-k>',
            ':ZellijNavigateUp<CR>',
            mode = { 'n' },
            desc = 'Focus on window up',
            noremap = true,
        },
        {
            '<C-j>',
            ':ZellijNavigateDown<CR>',
            mode = { 'n' },
            desc = 'Focus on window down',
            noremap = true,
        },
    },
}
