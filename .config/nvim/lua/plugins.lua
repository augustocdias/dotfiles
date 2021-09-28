require('packer').startup(function()
    use 'wbthomason/packer.nvim' -- package manager

    -- Auto completion and LSP
    use 'neovim/nvim-lspconfig' -- collection of LSP configurations for nvim
    use 'williamboman/nvim-lsp-installer' -- auto installers for language servers
    use {
        'hrsh7th/nvim-cmp', -- auto completion
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lua',
            { 'tzachar/cmp-tabnine', run='./install.sh' },
            'windwp/nvim-autopairs',
            { 'Saecki/crates.nvim', requires = { 'nvim-lua/plenary.nvim' } }
        }
    }
    use 'onsails/lspkind-nvim'
    use 'nvim-lua/lsp-status.nvim'
    use 'rafamadriz/friendly-snippets' -- snippets for many languages
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' } -- enhancements in highlighting and virtual text
    -- use 'jose-elias-alvarez/null-ls.nvim' -- can be useful to integrate with non LSP sources like eslint

    -- Helpers
    use {
        'folke/which-key.nvim',
        config = function()
            require("which-key").setup()
        end,
    } -- help with vim commands.
    use 'andymass/vim-matchup' -- Enhances the %
    use { -- gcc to comment/uncomment line
        'terrortylor/nvim-comment',
        config = function()
            require('nvim_comment').setup()
        end,
    }
    -- check https://github.com/blackCauldron7/surround.nvim
    -- use 'tpope/vim-surround' -- Add surround command to surround text with selected delimitter: http://futurile.net/2016/03/19/vim-surround-plugin-tutorial/
    use 'blackCauldron7/surround.nvim'
    use { -- enhance motion
        'IndianBoy42/hop.nvim',
        config = function()
            require('hop').setup()
        end,
    }

    -- UI and Themes
    use { 'shadmansaleh/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' } -- status line
    use 'monsonjeremy/onedark.nvim' -- theme
    use 'folke/tokyonight.nvim' -- theme
    use { 'romgrk/barbar.nvim', requires = 'kyazdani42/nvim-web-devicons' } -- tabline
    use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- show git indicators next to the line numbers (lines changed, added, etc.)
    use 'Yggdroot/indentLine' -- Adds a | to show indentation levels
    use { 'folke/todo-comments.nvim', requires = 'nvim-lua/plenary.nvim' } -- todo comments helper

    -- Misc
    use 'segeljakt/vim-silicon' -- Generates an image from selected text. Needs silicon installed (cargo install silicon)
    use 'ciaranm/securemodelines' -- https://vim.fandom.com/wiki/Modeline_magic
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'

    -- IDE stuff
    use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }
    use 'rmagatti/auto-session' -- session management
    use { 'akinsho/toggleterm.nvim' } -- better terminal
    -- use {
    --     'ray-x/navigator.lua',
    --     requires = { 'ray-x/guihua.lua', run = 'cd lua/fzy && make' }
    -- } -- code analysis.
    use {
        'ibhagwan/fzf-lua',
        requires = {
            'vijaymarupudi/nvim-fzf',
            'kyazdani42/nvim-web-devicons'
        }
    }
    use 'GustavoKatel/sidebar.nvim'

    -- rust
    use 'simrat39/rust-tools.nvim' -- rust support enhancements

    -- java
    use 'mfussenegger/nvim-jdtls' -- TODO configure

    -- debug
    -- check https://github.com/Pocco81/DAPInstall.nvim
    use 'mfussenegger/nvim-dap' -- debug adapter for debugging
    use 'theHamsta/nvim-dap-virtual-text' -- virtual text during debugging
    use 'rcarriga/nvim-dap-ui' -- ui for nvim-dap
end)
