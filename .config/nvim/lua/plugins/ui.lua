return {
    { 'rcarriga/nvim-notify', config = require('setup.notify').setup }, -- overides the default vim notify method for a floating window
    -- { 'j-hui/fidget.nvim', config = require('setup.fidget').setup }, -- status progress for lsp servers
    {
        'nvim-lualine/lualine.nvim',
        event = 'UIEnter',
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
        config = function()
            require('setup.catppuccin').setup('latte')
        end,
    }, -- theme
    {
        -- 'romgrk/barbar.nvim',
        'nanozuki/tabby.nvim',
        -- requires = { -- tabline
        --     'tiagovla/scope.nvim', -- creates scopes for splitting buffers per tabs
        -- },
        config = require('setup.tabline').setup,
    },
    { 'lewis6991/gitsigns.nvim', config = require('setup.gitsigns').setup }, -- show git indicators next to the line numbers (lines changed, added, etc.)
    {
        'sindrets/diffview.nvim',
        config = function()
            require('diffview').setup()
        end,
    }, -- creates a tab focd on diff view and git history
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        config = require('setup.blankline').setup,
    }, -- Adds a | to show indentation levels
    { 'folke/todo-comments.nvim', config = require('setup.todo-comments').setup }, -- todo comments helper
    {
        'wyattjsmith1/weather.nvim',
        cond = should_load_remote,
        config = require('setup.weather').setup,
    }, -- adds weather information to status line
    {
        'zbirenbaum/neodim',
        event = 'LspAttach',
        cond = should_load_remote,
        config = require('setup.neodim').setup,
    },
    {
        'KadoBOT/nvim-spotify',
        build = 'make',
        cond = should_load_remote,
        config = function()
            require('nvim-spotify').setup({
                update_interval = 5000,
            })
        end,
    },
}
