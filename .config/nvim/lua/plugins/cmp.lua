return {
    'hrsh7th/nvim-cmp', -- auto completion
    config = require('setup.cmp').setup,
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'rafamadriz/friendly-snippets', -- snippets for many languages
        'chrisgrieser/nvim-scissors', -- snippet editor
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-cmdline',
        { 'tzachar/cmp-tabnine', build = './install.sh' },
        'windwp/nvim-autopairs', -- helps with auto closing blocks
        { 'Saecki/crates.nvim', dependencies = { 'nvim-lua/plenary.nvim' } }, -- auto complete for Cargo.toml
        'onsails/lspkind-nvim', -- show pictograms in the auto complete popup
        'hrsh7th/cmp-nvim-lsp-document-symbol',
        'b0o/schemastore.nvim', -- adds schemas for json lsp
        {
            'zbirenbaum/copilot-cmp',
            dependencies = { 'zbirenbaum/copilot.lua' },
        },
        -- use({ 'github/copilot.vim' }), -- before first time using the lua version, this has to be installed and then run :Copilot to setup. Uninstall afterwards
    },
}
