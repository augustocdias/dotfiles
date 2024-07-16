-- selene: allow(mixed_table)
return {
    { 'rmagatti/auto-session', enabled = not vim.g.vscode },
    { 'dgrbrady/nvim-docker',  enabled = false }, -- docker manager. TODO: enable and configure when needed
    {
        'mistricky/codesnap.nvim',
        enabled = not vim.g.vscode,
        build = 'make',
        event = 'VeryLazy',
        config = function()
            require('setup.codesnap').setup()
        end,
    }, -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
    {
        'bennypowers/nvim-regexplainer',
        enabled = not vim.g.vscode,
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
        'akinsho/toggleterm.nvim',
        event = 'VeryLazy',
        enabled = not vim.g.vscode,
        config = require('setup.toggleterm').setup,
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
        dependencies = { 'nvim-telescope/telescope.nvim' },
        config = require('setup.session').setup,
    },
}
