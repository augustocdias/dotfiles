-- auto installer for lsp servers and linters

return {
    'williamboman/mason.nvim', -- lsp server installer
    enabled = not vim.g.vscode,
    -- opts = { log_level = vim.log.levels.DEBUG },
    dependencies = {
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        { 'Zeioth/none-ls-autoload.nvim', config = true },
    },
    config = function()
        require('mason').setup()
        require('mason-lspconfig').setup({
            ensure_installed = {
                'rust_analyzer',
                'lua_ls',
                'yamlls',
                'jsonls',
                'sqlls',
                'taplo',
                'dockerls',
                'docker_compose_language_service',
                'bashls',
                'ts_ls',
            },
            automatic_installation = true,
        })
        require('mason-tool-installer').setup({
            ensure_installed = {
                'codelldb',
                'harper_ls',
                'black',
                'markdownlint',
                'shfmt',
                'stylua',
                'codespell',
                'vale',
                'selene',
                'write-good',
                'yamllint',
                'sqlfluff',
            },
        })
    end,
}
