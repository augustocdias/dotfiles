return {
    definitions = function(use)
        use({
            'hrsh7th/nvim-cmp', -- auto completion
            config = require('setup.cmp').setup,
            requires = {
                'hrsh7th/cmp-nvim-lsp',
                'L3MON4D3/LuaSnip',
                'saadparwaiz1/cmp_luasnip',
                'rafamadriz/friendly-snippets', -- snippets for many languages
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-cmdline',
                { 'tzachar/cmp-tabnine', run = './install.sh' },
                'windwp/nvim-autopairs', -- helps with auto closing blocks
                'Saecki/crates.nvim', -- auto complete for Cargo.toml
                'onsails/lspkind-nvim', -- show pictograms in the auto complete popup
                'hrsh7th/cmp-nvim-lsp-document-symbol',
                'b0o/schemastore.nvim', -- adds schemas for json lsp
                {
                    'zbirenbaum/copilot-cmp',
                    module = 'copilot_cmp',
                    requires = { 'zbirenbaum/copilot.lua' },
                },
                -- use({ 'github/copilot.vim' }), -- before first time using the lua version, this has to be installed and then run :Copilot to setup. Uninstall afterwards
            },
        }) -- auto complete, its sources and utilities
    end,
}
