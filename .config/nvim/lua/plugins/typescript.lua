-- typescript enhancements

return {
    'pmizio/typescript-tools.nvim',
    enabled = not vim.g.vscode,
    ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    config = function()
        local lsp_utils = require('utils.lsp')
        require('typescript-tools').setup({
            capabilities = lsp_utils.capabilities(),
            on_attach = function(client, bufnr)
                lsp_utils.on_attach(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end,
            settings = {
                code_lens = 'all',
                publish_diagnostic_on = 'change',
                expose_as_code_action = 'all',
                tsserver_file_preferences = {
                    includeCompletionsForModuleExports = true,
                    includeCompletionsForImportStatements = true,
                    includeCompletionsWithSnippetText = true,
                    includeAutomaticOptionalChainCompletions = true,
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = 'all',
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                    quotePreference = 'auto',
                },
            },
        })
    end,
}
