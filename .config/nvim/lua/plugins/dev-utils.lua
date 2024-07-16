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
        enabled = not vim.g.vscode,
        config = require('setup.trouble').setup,
    }, -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
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
        config = true,
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
        config = true,
    }, -- creates a tab focd on diff view and git history
    {
        'NeogitOrg/neogit',
        enabled = not vim.g.vscode,
        cmd = 'Neogit',
        config = require('setup.neogit').setup,
    },                           -- git UI
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
    },
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
