require('packer').startup({
    function(use)
        use('lewis6991/impatient.nvim') -- speedup lua module load time
        use('ciaranm/securemodelines') -- https://vim.fandom.com/wiki/Modeline_magic
        use('nathom/filetype.nvim') -- replaces filetype load from vim for a more performant one
        use('wbthomason/packer.nvim') -- package manager

        -- Auto completion and LSP
        use({
            'neovim/nvim-lspconfig',
            requires = {
                'williamboman/mason.nvim',
                'williamboman/mason-lspconfig.nvim',
                'WhoIsSethDaniel/mason-tool-installer.nvim',
            },
        }) -- collection of LSP configurations for nvim
        use({
            'hrsh7th/nvim-cmp', -- auto completion
            requires = {
                'hrsh7th/cmp-nvim-lsp',
                'L3MON4D3/LuaSnip',
                'saadparwaiz1/cmp_luasnip',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-cmdline',
                { 'tzachar/cmp-tabnine', run = './install.sh' },
                'windwp/nvim-autopairs',
                { 'Saecki/crates.nvim', requires = { 'nvim-lua/plenary.nvim' }, branch = 'main' },
                'hrsh7th/cmp-nvim-lsp-document-symbol',
                {
                    'zbirenbaum/copilot-cmp',
                    module = 'copilot_cmp',
                    requires = { 'zbirenbaum/copilot.lua' },
                },
                -- use({ 'github/copilot.vim' }), -- before first time using the lua version, this has to be installed and then run :Copilot to setup. Uninstall afterwards
            },
        })
        use('onsails/lspkind-nvim') -- show pictograms in the auto complete popup
        use('rafamadriz/friendly-snippets') -- snippets for many languages
        use({ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }) -- enhancements in highlighting and virtual text
        use('nvim-treesitter/playground') -- TS PLayground for creating queries
        use({ 'jose-elias-alvarez/null-ls.nvim', requires = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' } }) -- can be useful to integrate with non LSP sources like eslint
        use({
            'jose-elias-alvarez/nvim-lsp-ts-utils',
            requires = { 'jose-elias-alvarez/null-ls.nvim', 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
        }) -- improve typescript
        use('ray-x/lsp_signature.nvim') -- show signature from methods as float windows
        use('b0o/schemastore.nvim') -- adds schemas for json lsp
        -- use({ 'github/copilot.vim', requires = { 'hrsh7th/cmp-copilot' } }) -- github copilot

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
        use('kylechui/nvim-surround') -- add surround commands
        use('ggandor/leap.nvim') -- hop to different parts of the buffer with s + character
        use('booperlv/nvim-gomove') -- makes better line moving
        use('nvim-pack/nvim-spectre') -- special search and replace buffer

        -- UI and Themes
        use('stevearc/dressing.nvim') -- overrides the default vim input to provide better visuals
        use('rcarriga/nvim-notify') -- overides the default vim notify method for a floating window
        use('j-hui/fidget.nvim') -- status progress for lsp servers
        use({ 'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' }) -- status line
        use({ 'augustocdias/tokyonight.nvim', opt = true }) -- theme TODO: switch back to folke when PR is merged
        use({ 'olimorris/onedarkpro.nvim' }) -- theme
        use({ 'catppuccin/nvim' }) -- theme
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
        use({ 'dgrbrady/nvim-docker', opt = true }) -- docker manager. TODO: enable and configure when needed
        use({ 'zbirenbaum/neodim', event = 'LspAttach', config = require('setup.neodim').setup })

        -- Misc
        use('segeljakt/vim-silicon') -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
        use({
            'luukvbaal/stabilize.nvim',
            config = function()
                require('stabilize').setup()
            end,
        }) -- stabilize buffer content on window open/close events
        use('farmergreg/vim-lastplace') -- remembers cursor position with nice features in comparison to just an autocmd
        use({ 'bennypowers/nvim-regexplainer', opt = true }) -- shows popup explaining regex under cursor
        use('augustocdias/gatekeeper.nvim') -- sets buffers outside the cwd as readonly
        use('nvim-lua/popup.nvim')
        use('nvim-lua/plenary.nvim')

        -- IDE stuff
        use({ 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }) -- file browser
        use('rmagatti/auto-session') -- session management
        use('akinsho/toggleterm.nvim') -- better terminal
        use({
            'nvim-telescope/telescope.nvim',
            requires = {
                'nvim-lua/plenary.nvim',
                'kyazdani42/nvim-web-devicons',
                'gbrlsnchs/telescope-lsp-handlers.nvim',
                'nvim-telescope/telescope-dap.nvim',
                'nvim-telescope/telescope-live-grep-raw.nvim',
                'nvim-telescope/telescope-file-browser.nvim',
                'nvim-telescope/telescope-symbols.nvim',
                { 'rmagatti/session-lens', requires = { 'rmagatti/auto-session' } },
                { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
            },
        })
        use('SmiteshP/nvim-navic') -- adds breadcrumbs
        use({
            'folke/trouble.nvim',
            requires = 'kyazdani42/nvim-web-devicons',
        }) -- adds a bottom panel with lsp diagnostics, quickfixes, etc.
        use('GustavoKatel/sidebar.nvim') -- useful sidebar with todos, git status, etc.
        use({
            'nvim-neotest/neotest',
            requires = {
                'nvim-lua/plenary.nvim',
                'nvim-treesitter/nvim-treesitter',
                'antoinemadec/FixCursorHold.nvim',
                'rouge8/neotest-rust',
            },
        }) -- test helpers. runs and show signs of test runs
        use({
            'pwntester/octo.nvim',
            requires = {
                'nvim-lua/plenary.nvim',
                'nvim-telescope/telescope.nvim',
                'kyazdani42/nvim-web-devicons',
            },
            config = function()
                require('octo').setup()
            end,
        }) -- github manager for issues and pull requests

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
    config = { max_jobs = 10 },
})
