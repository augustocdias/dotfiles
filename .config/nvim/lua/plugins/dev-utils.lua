return {
    { 'SmiteshP/nvim-navic', config = require('setup.nvim-navic').setup }, -- adds breadcrumbs
    { 'folke/trouble.nvim', config = require('setup.trouble').setup }, -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
    { 'GustavoKatel/sidebar.nvim', config = require('setup.sidebar-nvim').setup }, -- ful sidebar with todos, git status, etc.
    {
        'nvim-neotest/neotest',
        dependencies = {
            'rouge8/neotest-rust',
        },
        config = require('setup.neotest').setup,
    }, -- test helpers. runs and show signs of test runs
    {
        'pwntester/octo.nvim',
        config = function()
            require('octo').setup()
        end,
    }, -- github manager for issues and pull requests
    { 'NeogitOrg/neogit', config = require('setup.neogit').setup },
    {
        'mfussenegger/nvim-dap', -- debug adapter for debugging
        dependencies = {
            'rcarriga/nvim-dap-ui', -- ui for nvim-dap
            'theHamsta/nvim-dap-virtual-text', -- virtual text during debugging
        },
        config = require('setup.dap').setup,
    },
    { 'stevearc/overseer.nvim', config = require('setup.overseer').setup },
}
