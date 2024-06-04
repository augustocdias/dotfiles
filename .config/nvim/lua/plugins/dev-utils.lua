-- selene: allow(mixed_table)
return {
    {
        'SmiteshP/nvim-navic',
        event = 'VeryLazy',
        enabled = not vim.g.vscode,
        config = require('setup.nvim-navic').setup,
    }, -- adds breadcrumbs
    {
        'folke/trouble.nvim',
        event = 'VeryLazy',
        enabled = not vim.g.vscode,
        config = require('setup.trouble').setup,
    }, -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
    {
        'GustavoKatel/sidebar.nvim',
        event = 'VeryLazy',
        enabled = not vim.g.vscode,
        config = require('setup.sidebar-nvim').setup,
    }, -- ful sidebar with todos, git status, etc.
    {
        'nvim-neotest/neotest',
        enabled = not vim.g.vscode,
        dependencies = {
            'rouge8/neotest-rust',
            'nvim-neotest/nvim-nio',
            'nvim-lua/plenary.nvim',
        },
        cmd = 'Neotest',
        config = require('setup.neotest').setup,
    }, -- test helpers. runs and show signs of test runs
    {
        'pwntester/octo.nvim',
        enabled = not vim.g.vscode,
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons',
        },
        cmd = 'Octo',
        config = function()
            require('octo').setup()
        end,
    }, -- github manager for issues and pull requests
    {
        'sindrets/diffview.nvim',
        enabled = not vim.g.vscode,
        cmd = {
            'DiffviewOpen',
            'DiffviewRefresh',
            'DiffviewFocusFiles',
            'DiffviewFileHistory',
            'DiffviewToggleFiles',
        },
        config = function()
            require('diffview').setup()
        end,
    }, -- creates a tab focd on diff view and git history
    {
        'SuperBo/fugit2.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim',
            'nvim-tree/nvim-web-devicons',
            'nvim-lua/plenary.nvim',
            {
                'chrisgrieser/nvim-tinygit',
                dependencies = { 'stevearc/dressing.nvim' },
            },
        },
        cmd = { 'Fugit2', 'Fugit2Diff', 'Fugit2Graph' },
    }, -- git UI
    {
        'NeogitOrg/neogit',
        enabled = not vim.g.vscode,
        cmd = 'Neogit',
        config = require('setup.neogit').setup,
    },
    {
        'mfussenegger/nvim-dap', -- debug adapter for debugging
        enabled = not vim.g.vscode,
        event = 'VeryLazy',
        dependencies = {
            'rcarriga/nvim-dap-ui',            -- ui for nvim-dap
            'theHamsta/nvim-dap-virtual-text', -- virtual text during debugging
            'nvim-neotest/nvim-nio',
        },
        config = require('setup.dap').setup,
    }, -- another git UI... TODO: evaluate and choose
    {
        'stevearc/overseer.nvim',
        enabled = not vim.g.vscode,
        cmd = {
            'Overseer',
            'OverseerRun',
            'OverseerRunCmd',
            'OverseerBuild',
            'OverseerQuickAction',
            'OverseerTaskAction',
        },
        config = require('setup.overseer').setup,
    }, -- A task runner inspired by VSCode
}
