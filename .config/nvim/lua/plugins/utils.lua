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
        'rmagatti/auto-session',
        enabled = not vim.g.vscode,
        config = require('setup.session').setup,
    }, -- session management
    {
        'swaits/zellij-nav.nvim',
        lazy = true,
        event = 'VeryLazy',
        config = true,
    }, -- integrates focus on windows with zellij panes
}
