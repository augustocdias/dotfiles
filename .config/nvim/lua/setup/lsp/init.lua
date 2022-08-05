local lspconfig = require('lspconfig')

local on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        require('nvim-navic').attach(client, bufnr)
    end
    require('aerial').on_attach(client, bufnr)

    require('setup.autocommand').lsp_autocmds(client, bufnr)
    -- check if this is applicable (for rust for example it is not)
    -- https://github.com/L3MON4D3/LuaSnip/wiki/Misc#improve-language-server-snippets
end
local capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
    return capabilities
end
return {
    on_attach = on_attach,
    capabilities = capabilities,
    config_defaults = function()
        -- bash
        lspconfig.bashls.setup({
            on_attach = on_attach,
            capabilities = capabilities(),
        })
        -- C#
        lspconfig.omnisharp.setup({
            on_attach = on_attach,
            capabilities = capabilities(),
        })
        -- python
        lspconfig.pyright.setup({
            on_attach = on_attach,
            capabilities = capabilities(),
        })
        -- yaml
        lspconfig.yamlls.setup({
            on_attach = on_attach,
            capabilities = capabilities(),
        })
        -- json
        lspconfig.jsonls.setup({
            on_attach = on_attach,
            capabilities = capabilities(),
            commands = {
                Format = {
                    function()
                        vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line('$'), 0 })
                    end,
                },
            },
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                },
            },
        })
        -- docker
        lspconfig.dockerls.setup({
            on_attach = on_attach,
            capabilities = capabilities(),
        })
        -- deno
        -- ensure_server('denols'):setup({})
        -- sql
        lspconfig.sqlls.setup({
            on_attach = on_attach,
            capabilities = capabilities(),
            cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
        })
        -- kotlin
        lspconfig.kotlin_language_server.setup({
            on_attach = on_attach,
            capabilities = capabilities(),
        })
    end,
    setup = function()
        require('mason').setup()
        require('mason-lspconfig').setup({
            ensure_installed = { 'jdtls' },
            automatic_installation = true,
        })
        require('mason-tool-installer').setup({
            ensure_installed = {
                'codelldb',
                'eslint_d',
                'black',
                'clangd',
                'ktlint',
                'markdownlint',
                'shfmt',
                'stylua',
                'codespell',
                'vale',
                'luacheck',
                'pylint',
                'write-good',
                'yamllint',
                'cmakelang',
            },
        })
        -- general LSP config
        vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            underline = true,
            update_in_insert = true,
            virtual_text = false,
            signs = true,
        })

        -- show icons in the sidebar
        local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

        for type, icon in pairs(signs) do
            local hl = 'DiagnosticSign' .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
        vim.fn.sign_define(
            'LightBulbSign',
            { text = '💡', texthl = 'LspDiagnosticsDefaultInformation', numhl = 'LspDiagnosticsDefaultInformation' }
        )

        vim.diagnostic.config({
            severity_sort = true,
        })
        return lspconfig
    end,
}
