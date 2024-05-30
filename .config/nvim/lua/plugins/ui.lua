return {
    { 'MunifTanjim/nui.nvim',   enabled = not vim.g.vscode }, -- base ui components for nvim
    { 'stevearc/dressing.nvim', enabled = not vim.g.vscode }, -- overrides the default vim input to provide better visuals
    {
        'rcarriga/nvim-notify',
        enabled = not vim.g.vscode,
        config = require('setup.notify').setup,
    }, -- overides the default vim notify method for a floating window
    -- { 'j-hui/fidget.nvim', config = require('setup.fidget').setup }, -- status progress for lsp servers
    {
        'nvim-lualine/lualine.nvim',
        event = 'UIEnter',
        enabled = not vim.g.vscode,
        config = function()
            local signature = require('setup.lsp_signature')
            local weather = require('setup.weather')
            local cmd_color = require('setup.catppuccin').pallete('latte').teal
            require('setup.lualine').setup(
                signature.status_line,
                weather.status_line,
                require('setup.nvim-navic').winbar,
                require('setup.noice').command_status(cmd_color)
            )
        end,
    }, -- status line
    {
        'folke/noice.nvim',
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
        config = function()
            require('setup.catppuccin').setup('latte')
        end,
    }, -- theme
    {
        -- 'romgrk/barbar.nvim',
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
        'sindrets/diffview.nvim',
        enabled = not vim.g.vscode,
        cmd = 'LazyDiffView',
        config = function()
            require('diffview').setup()
        end,
    }, -- creates a tab focd on diff view and git history
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        enabled = not vim.g.vscode,
        config = require('setup.blankline').setup,
    }, -- Adds a | to show indentation levels
    {
        'folke/todo-comments.nvim',
        enabled = not vim.g.vscode,
        config = require('setup.todo-comments').setup,
    }, -- todo comments helper
    {
        'wyattjsmith1/weather.nvim',
        enabled = not vim.g.vscode,
        config = require('setup.weather').setup,
    }, -- adds weather information to status line
    {
        'zbirenbaum/neodim',
        enabled = not vim.g.vscode,
        event = 'LspAttach',
        config = require('setup.neodim').setup,
    },
}
