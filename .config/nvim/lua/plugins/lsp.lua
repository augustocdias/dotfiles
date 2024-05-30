return {
    {
        'williamboman/mason.nvim', -- lsp server installer
        enabled = not vim.g.vscode,
        config = function()
            require('mason').setup()
        end,
        dependencies = { 'williamboman/mason-lspconfig.nvim', 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    },
    {
        'neovim/nvim-lspconfig',
        enabled = not vim.g.vscode,
        config = function()
            local lspconfig = require('setup.lsp')
            local conf = lspconfig.setup()
            lspconfig.config_defaults()
            require('setup.lsp.lua').setup(conf, lspconfig.capabilities(), lspconfig.on_attach)
        end,
    },                          -- collection of LSP configurations for nvim
    {
        'stevearc/aerial.nvim', -- check if https://github.com/hedyhli/outline.nvim can replace it
        enabled = not vim.g.vscode,
        cmd = 'LazyAerial',
        config = require('setup.lsp.aerial').setup,
    }, -- show symbol tree in the current buffer
    {
        -- TODO: search for replacement as project was discontinued
        'jose-elias-alvarez/null-ls.nvim',
        enabled = not vim.g.vscode,
        dependencies = 'ThePrimeagen/refactoring.nvim', -- refactoring library used by null-ls
        config = function()
            local lspconfig = require('setup.lsp')
            require('setup.lsp.null-ls').setup(lspconfig.on_attach)
        end,
    }, -- can be ful to integrate with non LSP sources like eslint
    {
        'ray-x/lsp_signature.nvim',
        enabled = not vim.g.vscode,
        dependencies = 'nvim-lspconfig',
        config = require('setup.lsp_signature').setup,
    }, -- show signature from methods as float windows
    {
        'mfussenegger/nvim-jdtls',
        enabled = not vim.g.vscode,
        ft = { 'java', 'gradle' },
        config = function()
            local lspconfig = require('setup.lsp')
            require('setup.lsp.java').setup(lspconfig.capabilities(), lspconfig.on_attach)
        end,
    }, -- java enhancements
    {
        'mrcjkb/rustaceanvim',
        enabled = not vim.g.vscode,
        ft = { 'rust' },
        config = function() -- check https://github.com/vxpm/ferris.nvim
            local lspconfig = require('setup.lsp')
            local settings = require('setup.lsp.rust').setup(lspconfig.capabilities(), lspconfig.on_attach)
            vim.g.rustaceanvim = settings
        end,
    }, -- rust enhancements
    {
        'pmizio/typescript-tools.nvim',
        enabled = not vim.g.vscode,
        ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
        config = function()
            local lspconfig = require('setup.lsp')
            require('setup.lsp.typescript').setup(lspconfig.capabilities(), lspconfig.on_attach)
        end, -- typescript enhancements
    },
}
