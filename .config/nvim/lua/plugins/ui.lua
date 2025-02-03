-- selene: allow(mixed_table)
return {
    { 'MunifTanjim/nui.nvim', enabled = not vim.g.vscode }, -- base ui components for nvim
    {
        'nvim-lualine/lualine.nvim',
        event = 'UIEnter',
        enabled = not vim.g.vscode,
        config = function()
            local cmd_color = require('setup.catppuccin').noice_status_color('mocha')
            require('setup.lualine').setup(require('setup.noice').command_status(cmd_color))
        end,
    }, -- status line
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        enabled = not vim.g.vscode,
        dependencies = {
            'MunifTanjim/nui.nvim',
            'rcarriga/nvim-notify',
        },
        config = function()
            require('setup.noice').setup()
        end,
    }, -- adds various ui enhancements such as a popup for the cmd line, lsp progress
    {
        'catppuccin/nvim',
        enabled = not vim.g.vscode,
        priority = 99,
        config = function()
            require('setup.catppuccin').setup('mocha')
        end,
    }, -- theme
    {
        'nanozuki/tabby.nvim',
        enabled = not vim.g.vscode,
        -- requires = { -- tabline
        --     'tiagovla/scope.nvim', -- creates scopes for splitting buffers per tabs
        -- },
        config = require('setup.tabline').setup,
    },
    {
        'lewis6991/gitsigns.nvim',
        enabled = not vim.g.vscode,
        config = require('setup.gitsigns').setup,
    }, -- show git indicators next to the line numbers (lines changed, added, etc.)
    {
        'folke/todo-comments.nvim',
        enabled = not vim.g.vscode,
        config = require('setup.todo-comments').setup,
    }, -- todo comments helper
    {
        'MeanderingProgrammer/markdown.nvim',
        enabled = not vim.g.vscode,
        dependencies = {
            'nvim-tree/nvim-web-devicons', -- Used by the code bloxks
        },
        config = true,
    }, -- markdown enhancements -- check marvkview
    {
        'OXY2DEV/helpview.nvim',
        lazy = false,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
    }, -- help buffers enhancements
    {
        'carbon-steel/detour.nvim',
        enabled = not vim.g.vscode,
        cmd = { 'Detour', 'DetourCurrentWindow' },
    }, -- opens popups with the current buffer to avoid missing the original spot
    {
        'kevinhwang91/nvim-ufo',
        enabled = not vim.g.vscode,
        event = 'VeryLazy',
        config = require('setup.ufo').setup,
        dependencies = { 'kevinhwang91/promise-async', 'luukvbaal/statuscol.nvim' },
    }, -- handling folds based on LSP and treesitter
}
