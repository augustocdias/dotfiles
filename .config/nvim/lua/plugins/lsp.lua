return {
    definitions = function(use)
        use('williamboman/mason.nvim')
        use('williamboman/mason-lspconfig.nvim')
        use('WhoIsSethDaniel/mason-tool-installer.nvim')
        use({
            'neovim/nvim-lspconfig',
            config = function()
                local lspconfig = require('setup.lsp')
                local conf = lspconfig.setup()
                lspconfig.config_defaults()
                require('setup.lsp.lua').setup(conf, lspconfig.capabilities(), lspconfig.on_attach)
            end,
        }) -- collection of LSP configurations for nvim
        use({
            'stevearc/aerial.nvim',
            config = require('setup.lsp.aerial').setup,
        })
        use({
            'jose-elias-alvarez/null-ls.nvim',
            requires = 'ThePrimeagen/refactoring.nvim',
            config = function()
                local lspconfig = require('setup.lsp')
                require('setup.lsp.null-ls').setup(lspconfig.on_attach)
            end,
        }) -- can be useful to integrate with non LSP sources like eslint
        use('jose-elias-alvarez/nvim-lsp-ts-utils') -- improve typescript
        use({ 'ray-x/lsp_signature.nvim', after = 'nvim-lspconfig', config = require('setup.lsp_signature').setup }) -- show signature from methods as float windows
        use({
            'mfussenegger/nvim-jdtls',
            ft = { 'java', 'gradle' },
            config = function()
                local lspconfig = require('setup.lsp')
                require('setup.lsp.java').setup(lspconfig.capabilities(), lspconfig.on_attach)
            end,
        }) -- java enhancements
        use({
            'simrat39/rust-tools.nvim',
            ft = { 'rust' },
            config = function()
                local lspconfig = require('setup.lsp')
                require('setup.lsp.rust').setup(lspconfig.capabilities(), lspconfig.on_attach)
            end,
        }) -- rust enhancements
    end,
}
