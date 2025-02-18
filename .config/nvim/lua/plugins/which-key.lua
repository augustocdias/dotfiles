-- Shows hints for the keybindings in a floating window.

return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
        icons = {
            breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
            separator = '󰔰', -- symbol used between a key and it's label
            group = '󰊳 ', -- symbol
        },
    },
    keys = {
        {
            '<leader>g',
            'rhs',
            mode = { 'n' },
            desc = 'Git',
            noremap = true,
        },
        {
            '<leader>h',
            'rhs',
            mode = { 'n', 'v' },
            desc = 'Gitsigns',
            noremap = true,
        },
        {
            '<leader>l',
            'rhs',
            mode = { 'n' },
            desc = 'LSP',
            noremap = true,
        },
        {
            '<leader>m',
            'rhs',
            mode = { 'n' },
            desc = 'Music',
            noremap = true,
        },
        {
            '<leader>n',
            'rhs',
            mode = { 'n' },
            desc = 'Refactoring',
            noremap = true,
        },
        {
            '<leader>p',
            'rhs',
            mode = { 'n' },
            desc = 'Grep',
            noremap = true,
        },
        {
            '<leader>r',
            'rhs',
            mode = { 'n' },
            desc = 'Rust',
            noremap = true,
        },
        {
            '<leader>s',
            'rhs',
            mode = { 'n' },
            desc = 'Surround',
            noremap = true,
        },
        {
            '<leader>t',
            'rhs',
            mode = { 'n' },
            desc = 'Trouble',
            noremap = true,
        },
        {
            '<leader>v',
            'rhs',
            mode = { 'n' },
            desc = 'Vim',
            noremap = true,
        },
    },
}
