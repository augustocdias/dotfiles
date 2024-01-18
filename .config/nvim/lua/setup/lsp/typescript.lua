return {
    setup = function(capabilities, on_attach)
        require('typescript-tools').setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                code_lens = 'all',
                tsserver_file_preferences = {
                    includeCompletionsForModuleExports = true,
                    includeCompletionsForImportStatements = true,
                    includeCompletionsWithSnippetText = true,
                    includeAutomaticOptionalChainCompletions = true,
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    quotePreference = 'auto',
                },
            },
        })
    end,
}
