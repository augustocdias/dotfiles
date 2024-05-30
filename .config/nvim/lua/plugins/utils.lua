return {
    { 'rmagatti/auto-session',         enabled = not vim.g.vscode },
    { 'dgrbrady/nvim-docker',          enabled = false }, -- docker manager. TODO: enable and configure when needed
    -- {
    --     'krivahtoo/silicon.nvim',
    --     build = './install.sh build',
    --     config = require('setup.silicon').setup,
    -- }, -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
    { 'bennypowers/nvim-regexplainer', enabled = not vim.g.vscode, cmd = 'LazyRegexplainer' }, -- shows popup explaining regex under cursor
    {
        'nvim-neo-tree/neo-tree.nvim',
        enabled = not vim.g.vscode,
        cmd = 'LazyTree',
        dependencies = { 'MunifTanjim/nui.nvim' },
        config = require('setup.neotree').setup,
    }, -- file browser
    {
        'stevearc/oil.nvim',
        enabled = not vim.g.vscode,
        config = require('setup.oil').setup,
    }, -- file browser. eventually should replace neo-tree
    {
        'akinsho/toggleterm.nvim',
        enabled = not vim.g.vscode,
        config = require('setup.toggleterm').setup,
    }, -- better terminal
    {
        'nvim-telescope/telescope.nvim',
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
