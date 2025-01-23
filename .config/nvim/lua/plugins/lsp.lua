-- selene: allow(mixed_table)
return {
    {
        'williamboman/mason.nvim', -- lsp server installer
        enabled = not vim.g.vscode,
        event = 'VeryLazy',
        config = true,
        -- opts = { log_level = vim.log.levels.DEBUG },
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            { 'Zeioth/none-ls-autoload.nvim', config = true },
        },
    },
    {
        'neovim/nvim-lspconfig',
        event = 'VeryLazy',
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
        cmd = {
            'AerialToggle',
            'AerialOpenAll',
            'AerialCloseAll',
            'AerialTreeSyncFolds',
            'AerialInfo',
        },
        config = require('setup.lsp.aerial').setup,
    }, -- show symbol tree in the current buffer
    {
        'nvimtools/none-ls.nvim',
        event = 'VeryLazy',
        enabled = not vim.g.vscode,
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
            'ThePrimeagen/refactoring.nvim', -- provide refactoring actions
        },
        config = function()
            local lspconfig = require('setup.lsp')
            require('setup.lsp.none-ls').setup(lspconfig.on_attach)
        end,
    }, -- can be useful to integrate with non LSP sources like eslint
    {
        'mrcjkb/rustaceanvim',
        enabled = not vim.g.vscode,
        dependencies = {
            { 'Saecki/crates.nvim', dependencies = { 'nvim-lua/plenary.nvim' } }, -- auto complete for Cargo.toml
        },
        init = function()
            vim.g.rustaceanvim = function()
                local lspconfig = require('setup.lsp')
                local settings = require('setup.lsp.rust').setup(lspconfig.capabilities(), lspconfig.on_attach)
                return settings
            end
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
