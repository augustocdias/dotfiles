require('packer').startup({
    function(use)
        use('wbthomason/packer.nvim') -- package manager

        -- Auto completion and LSP
        use('neovim/nvim-lspconfig') -- collection of LSP configurations for nvim
        use('williamboman/nvim-lsp-installer') -- auto installers for language servers
        use({
            'hrsh7th/nvim-cmp', -- auto completion
            requires = {
                'hrsh7th/cmp-nvim-lsp',
                'L3MON4D3/LuaSnip',
                'saadparwaiz1/cmp_luasnip',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-nvim-lua',
                { 'tzachar/cmp-tabnine', run = './install.sh' },
                'windwp/nvim-autopairs',
                { 'Saecki/crates.nvim', requires = { 'nvim-lua/plenary.nvim' }, branch = 'main' },
            },
        })
        use('onsails/lspkind-nvim') -- show pictograms in the auto complete popup
        use('nvim-lua/lsp-status.nvim') -- get status from lsp to show in status line
        use('rafamadriz/friendly-snippets') -- snippets for many languages
        use({ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }) -- enhancements in highlighting and virtual text
        use({ 'jose-elias-alvarez/null-ls.nvim', requires = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' } }) -- can be useful to integrate with non LSP sources like eslint
        use({
            'jose-elias-alvarez/nvim-lsp-ts-utils',
            requires = { 'jose-elias-alvarez/null-ls.nvim', 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
        }) -- improve typescript
        use({ 'ray-x/lsp_signature.nvim' }) -- show signature from methods as float windows
        use('b0o/schemastore.nvim') -- adds schemas for json lsp

        -- Helpers
        use('tpope/vim-repeat') -- adds repeat functionality for other plugins
        use({
            'folke/which-key.nvim',
            config = function()
                require('which-key').setup()
            end,
        }) -- help with vim commands.
        use('andymass/vim-matchup') -- Enhances the %
        use('numToStr/Comment.nvim') -- gcc to comment/uncomment line
        use('blackCauldron7/surround.nvim') -- add surround commands
        use('ggandor/lightspeed.nvim') -- hop to different parts of the buffer with s + character
        use('booperlv/nvim-gomove') -- makes better line moving
        use('nvim-pack/nvim-spectre') -- special search and replace buffer

        -- UI and Themes
        use('stevearc/dressing.nvim') -- overrides the default vim input to provide better visuals
        use('rcarriga/nvim-notify') -- overides the default vim notify method for a floating window
        use('j-hui/fidget.nvim') -- status progress for lsp servers
        use({ 'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' }) -- status line
        use('folke/tokyonight.nvim') -- theme
        use({ 'lalitmee/cobalt2.nvim', requires = 'tjdevries/colorbuddy.nvim' }) -- theme
        use({ 'romgrk/barbar.nvim', requires = 'kyazdani42/nvim-web-devicons' }) -- tabline
        use({ 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }) -- show git indicators next to the line numbers (lines changed, added, etc.)
        use({ 'sindrets/diffview.nvim', requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' } }) -- creates a tab focused on diff view and git history
        use('lukas-reineke/indent-blankline.nvim') -- Adds a | to show indentation levels
        use({ 'folke/todo-comments.nvim', requires = 'nvim-lua/plenary.nvim' }) -- todo comments helper
        use({
            'wyattjsmith1/weather.nvim',
            requires = {
                'nvim-lua/plenary.nvim',
            },
        }) -- adds weather information to status line

        -- Misc
        use('segeljakt/vim-silicon') -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
        use('ciaranm/securemodelines') -- https://vim.fandom.com/wiki/Modeline_magic
        use('lewis6991/impatient.nvim') -- speedup lua module load time
        use('nathom/filetype.nvim') -- replaces filetype load from vim for a more performant one
        use({
            'luukvbaal/stabilize.nvim',
            config = function()
                require('stabilize').setup()
            end,
        }) -- stabilize buffer content on window open/close events
        use('nvim-lua/popup.nvim')
        use('nvim-lua/plenary.nvim')

        -- IDE stuff
        use({ 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }) -- file browser
        use('rmagatti/auto-session') -- session management
        use({ 'akinsho/toggleterm.nvim' }) -- better terminal
        use({
            'nvim-telescope/telescope.nvim',
            requires = {
                'nvim-lua/plenary.nvim',
                'kyazdani42/nvim-web-devicons',
                'gbrlsnchs/telescope-lsp-handlers.nvim',
                'nvim-telescope/telescope-dap.nvim',
                'nvim-telescope/telescope-live-grep-raw.nvim',
                { 'rmagatti/session-lens', requires = { 'rmagatti/auto-session' } },
                { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
            },
        })
        use({
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
        }) -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
        use('GustavoKatel/sidebar.nvim') -- useful sidebar with todos, git status, etc.
        use({ 'rcarriga/vim-ultest', requires = { 'vim-test/vim-test' }, run = ':UpdateRemotePlugins' }) -- test helpers. runs and show signs of test runs

        -- rust
        use('simrat39/rust-tools.nvim') -- rust support enhancements

        -- java
        use('mfussenegger/nvim-jdtls') -- java support enhancements

        -- debug
        -- check https://github.com/Pocco81/DAPInstall.nvim
        use('mfussenegger/nvim-dap') -- debug adapter for debugging
        use('theHamsta/nvim-dap-virtual-text') -- virtual text during debugging
        use('rcarriga/nvim-dap-ui') -- ui for nvim-dap
    end,
    config = { compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua', max_jobs = 10 },
})
