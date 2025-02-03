-- selene: allow(mixed_table)
return {
    {
        'mistricky/codesnap.nvim',
        enabled = false,
        build = 'make',
        event = 'VeryLazy',
        config = function()
            require('setup.codesnap').setup()
        end,
    }, -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
    {
        'bennypowers/nvim-regexplainer',
        enabled = false,
        cmd = { 'RegexplainerShowSplit', 'RegexplainerShowPopup', 'RegexplainerToggle', 'RegexplainerYank' },
    }, -- shows popup explaining regex under cursor
    {
        'echasnovski/mini.files',
        version = false,
        event = 'VeryLazy',
        enabled = not vim.g.vscode,
        config = require('setup.mini.files').setup,
    }, -- file browser. eventually should replace neo-tree
    {
        'jaimecgomezz/here.term',
        event = 'VeryLazy',
        enabled = false,
        config = require('setup.terminal').setup,
    }, -- better terminal
    {
        'nvim-telescope/telescope.nvim',
        event = 'VeryLazy',
        enabled = not vim.g.vscode,
        dependencies = { -- pickers
            'gbrlsnchs/telescope-lsp-handlers.nvim',
            'nvim-telescope/telescope-dap.nvim',
            'nvim-telescope/telescope-live-grep-raw.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
            'nvim-telescope/telescope-symbols.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = require('setup.telescope').setup,
    },
    -- session management and picker
    {
        'rmagatti/auto-session',
        enabled = not vim.g.vscode,
        lazy = vim.g.leetcode_enabled,
        dependencies = { 'nvim-telescope/telescope.nvim' },
        config = require('setup.session').setup,
    },
    {
        'swaits/zellij-nav.nvim',
        lazy = true,
        event = 'VeryLazy',
        config = true,
    },
}
