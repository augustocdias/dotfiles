-- auto installer for lsp servers and linters

return {
    'williamboman/mason.nvim', -- lsp server installer
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
                'emmylua_ls',
                'yamlls',
                'jsonls',
                'sqlls',
                'taplo',
                'dockerls',
                'docker_compose_language_service',
                'bashls',
                'ts_ls',
                'eslint',
            },
            automatic_installation = true,
            automatic_enable = false,
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
                'selene',
                'write-good',
                'yamllint',
                'sqlfluff',
                'hadolint',
                'actionlint',
            },
        })
    end,
}
