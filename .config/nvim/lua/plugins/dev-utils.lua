return {
    {
        'SmiteshP/nvim-navic',
        cond = should_load_remote,
        config = require('setup.nvim-navic').setup,
    }, -- adds breadcrumbs
    {
        'folke/trouble.nvim',
        cond = should_load_remote,
        config = require('setup.trouble').setup,
    },                                                                             -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
    { 'GustavoKatel/sidebar.nvim', config = require('setup.sidebar-nvim').setup }, -- ful sidebar with todos, git status, etc.
    {
        'nvim-neotest/neotest',
        cond = should_load_remote,
        dependencies = {
            'rouge8/neotest-rust',
        },
        config = require('setup.neotest').setup,
    }, -- test helpers. runs and show signs of test runs
    {
        'pwntester/octo.nvim',
        cond = should_load_remote,
        config = function()
            require('octo').setup()
        end,
    }, -- github manager for issues and pull requests
    {
        'NeogitOrg/neogit',
        cond = should_load_remote,
        config = require('setup.neogit').setup,
    },
    {
        'mfussenegger/nvim-dap', -- debug adapter for debugging
        cond = should_load_remote,
        dependencies = {
            'rcarriga/nvim-dap-ui',            -- ui for nvim-dap
            'theHamsta/nvim-dap-virtual-text', -- virtual text during debugging
        },
        config = require('setup.dap').setup,
    },
    {
        'stevearc/overseer.nvim',
        cond = should_load_remote,
        config = require('setup.overseer').setup,
    },
}
