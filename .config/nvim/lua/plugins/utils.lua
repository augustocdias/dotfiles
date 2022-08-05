return {
    definitions = function(use)
        use({ 'dgrbrady/nvim-docker', opt = true }) -- docker manager. TODO: enable and configure when needed
        use('segeljakt/vim-silicon') -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
        use({
            'luukvbaal/stabilize.nvim',
            config = function()
                require('stabilize').setup()
            end,
        }) -- stabilize buffer content on window open/close events
        use({ 'bennypowers/nvim-regexplainer', opt = true }) -- shows popup explaining regex under cursor
        use({
            'nvim-neo-tree/neo-tree.nvim',
            requires = { 'MunifTanjim/nui.nvim', 'mrbjarksen/neo-tree-diagnostics.nvim' },
            config = require('setup.neotree').setup,
        }) -- file browser
        use({ 'akinsho/toggleterm.nvim', config = require('setup.toggleterm').setup }) -- better terminal
        use({
            'nvim-telescope/telescope.nvim',
            requires = {
                'gbrlsnchs/telescope-lsp-handlers.nvim',
                'nvim-telescope/telescope-dap.nvim',
                'nvim-telescope/telescope-live-grep-raw.nvim',
                'nvim-telescope/telescope-file-browser.nvim',
                'nvim-telescope/telescope-symbols.nvim',
                { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
            },
            config = require('setup.telescope').setup,
        })
        use({
            'rmagatti/session-lens',
            requires = 'rmagatti/auto-session',
            config = function()
                local neotree = require('setup.neotree')
                require('setup.session').setup(neotree.on_session_restore)
            end,
        }) -- session management
    end,
}
