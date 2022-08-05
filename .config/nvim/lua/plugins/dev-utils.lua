return {
    definitions = function(use)
        use({ 'SmiteshP/nvim-navic', config = require('setup.nvim-navic').setup }) -- adds breadcrumbs
        -- use('folke/trouble.nvim') -- adds a bottom panel with lsp diagnostics, quickfixes, etc. NOTE: using neo-tree diagnostics
        use({ 'GustavoKatel/sidebar.nvim', config = require('setup.sidebar-nvim').setup }) -- useful sidebar with todos, git status, etc.
        use({
            'nvim-neotest/neotest',
            requires = {
                'antoinemadec/FixCursorHold.nvim',
                'rouge8/neotest-rust',
            },
            config = require('setup.neotest').setup,
        }) -- test helpers. runs and show signs of test runs
        use({
            'pwntester/octo.nvim',
            config = function()
                require('octo').setup()
            end,
        }) -- github manager for issues and pull requests

        -- debug
        -- check https://github.com/Pocco81/DAPInstall.nvim
        use({
            'mfussenegger/nvim-dap', -- debug adapter for debugging
            requires = {
                'rcarriga/nvim-dap-ui', -- ui for nvim-dap
                'theHamsta/nvim-dap-virtual-text', -- virtual text during debugging
            },
            config = require('setup.dap').setup,
        })
    end,
}
