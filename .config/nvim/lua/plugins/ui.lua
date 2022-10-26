return {
    definitions = function(use)
        use({ 'rcarriga/nvim-notify', config = require('setup.notify').setup }) -- overides the default vim notify method for a floating window
        use({ 'j-hui/fidget.nvim', config = require('setup.fidget').setup }) -- status progress for lsp servers
        use({
            'nvim-lualine/lualine.nvim',
            config = function()
                local signature = require('setup.lsp_signature')
                local weather = require('setup.weather')
                require('setup.lualine').setup(
                    signature.status_line,
                    weather.status_line,
                    require('setup.nvim-navic').winbar,
                    require('setup.substitute').status_line
                )
            end,
        }) -- status line
        use({
            'catppuccin/nvim',
            config = function()
                require('setup.catppuccin').setup('latte')
            end,
        }) -- theme
        use({
            'romgrk/barbar.nvim',
            requires = { -- tabline
                'tiagovla/scope.nvim', -- creates scopes for splitting buffers per tabs
            },
            config = require('setup.bufferline').setup,
        })
        use({ 'lewis6991/gitsigns.nvim', config = require('setup.gitsigns').setup }) -- show git indicators next to the line numbers (lines changed, added, etc.)
        use({
            'sindrets/diffview.nvim',
            config = function()
                require('diffview').setup()
            end,
        }) -- creates a tab focused on diff view and git history
        use({ 'lukas-reineke/indent-blankline.nvim', config = require('setup.blankline').setup }) -- Adds a | to show indentation levels
        use({ 'folke/todo-comments.nvim', config = require('setup.todo-comments').setup }) -- todo comments helper
        use({ 'wyattjsmith1/weather.nvim', config = require('setup.weather').setup }) -- adds weather information to status line
        use({ 'zbirenbaum/neodim', event = 'LspAttach', config = require('setup.neodim').setup })
        use({
            'KadoBOT/nvim-spotify',
            run = 'make',
            config = function()
                require('nvim-spotify').setup({
                    update_interval = 5000,
                })
            end,
        })
    end,
}
