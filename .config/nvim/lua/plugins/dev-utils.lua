-- selene: allow(mixed_table)
return {
    {
        'Bekaboo/dropbar.nvim',
        config = true,
    },
    {
        'folke/trouble.nvim',
        enabled = not vim.g.vscode,
        config = require('setup.trouble').setup,
    }, -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
    {
        'nvim-neotest/neotest',
        enabled = false,
        dependencies = {
            'nvim-neotest/nvim-nio',
            'nvim-lua/plenary.nvim',
        },
        cmd = 'Neotest',
        config = require('setup.neotest').setup,
    }, -- test helpers. runs and show signs of test runs
    {
        'pwntester/octo.nvim',
        enabled = false,
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
        enabled = false,
        cmd = 'Neogit',
        config = require('setup.neogit').setup,
    },                           -- git UI
    {
        'mfussenegger/nvim-dap', -- debug adapter for debugging
        enabled = false,
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
            'OverseerToggle',
            'OverseerRun',
            'OverseerRunCmd',
            'OverseerBuild',
            'OverseerQuickAction',
            'OverseerTaskAction',
        },
        config = require('setup.overseer').setup,
    },                           -- A task runner inspired by VSCode
    {
        'windwp/nvim-autopairs', -- helps with auto closing blocks
        enabled = not vim.g.vscode,
        event = 'VeryLazy',
        config = require('setup.autopairs').setup,
    },
}
