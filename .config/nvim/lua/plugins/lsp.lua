return {
    {
        'williamboman/mason.nvim', -- lsp server installer
        cond = should_load_remote,
        config = function()
            require('mason').setup()
        end,
        dependencies = { 'williamboman/mason-lspconfig.nvim', 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    },
    {
        'neovim/nvim-lspconfig',
        cond = should_load_remote,
        config = function()
            local lspconfig = require('setup.lsp')
            local conf = lspconfig.setup()
            lspconfig.config_defaults()
            require('setup.lsp.lua').setup(conf, lspconfig.capabilities(), lspconfig.on_attach)
            require('setup.lsp.typescript').setup(conf, lspconfig.capabilities(), lspconfig.on_attach)
        end,
    },                          -- collection of LSP configurations for nvim
    {
        'stevearc/aerial.nvim', -- check if https://github.com/hedyhli/outline.nvim can replace it
        cond = should_load_remote,
        config = require('setup.lsp.aerial').setup,
    }, -- show symbol tree in the current buffer
    {
        'jose-elias-alvarez/null-ls.nvim',
        cond = should_load_remote,
        dependencies = 'ThePrimeagen/refactoring.nvim', -- refactoring library used by null-ls
        config = function()
            local lspconfig = require('setup.lsp')
            require('setup.lsp.null-ls').setup(lspconfig.on_attach)
        end,
    },                                      -- can be ful to integrate with non LSP sources like eslint
    'jose-elias-alvarez/nvim-lsp-ts-utils', -- improve typescript
    cond = should_load_remote,
    {
        'ray-x/lsp_signature.nvim',
        cond = should_load_remote,
        dependencies = 'nvim-lspconfig',
        config = require('setup.lsp_signature').setup,
    }, -- show signature from methods as float windows
    {
        'mfussenegger/nvim-jdtls',
        ft = { 'java', 'gradle' },
        cond = should_load_remote,
        config = function()
            local lspconfig = require('setup.lsp')
            require('setup.lsp.java').setup(lspconfig.capabilities(), lspconfig.on_attach)
        end,
    }, -- java enhancements
    {
        'mrcjkb/rustaceanvim',
        cond = should_load_remote,
        ft = { 'rust' },
        config = function() -- check https://github.com/vxpm/ferris.nvim
            local lspconfig = require('setup.lsp')
            local settings = require('setup.lsp.rust').setup(lspconfig.capabilities(), lspconfig.on_attach)
            vim.g.rustaceanvim = settings
        end,
    }, -- rust enhancements
}
