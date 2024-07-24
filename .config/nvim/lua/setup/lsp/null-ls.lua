return {
    setup = function(on_attach)
        require('refactoring').setup({})
        local null_ls = require('null-ls')
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.black,
                null_ls.builtins.formatting.clang_format,
                null_ls.builtins.formatting.cmake_format,
                null_ls.builtins.formatting.prettier,
                null_ls.builtins.formatting.fish_indent,
                null_ls.builtins.formatting.gofmt,
                null_ls.builtins.formatting.goimports,
                null_ls.builtins.formatting.ktlint,
                null_ls.builtins.formatting.markdownlint,
                null_ls.builtins.formatting.shfmt,
                null_ls.builtins.formatting.stylua.with({
                    extra_args = { '--config-path', vim.fn.expand('~/.config/stylua.toml') },
                }),
                null_ls.builtins.diagnostics.actionlint,
                null_ls.builtins.diagnostics.codespell.with({
                    filetypes = { 'markdown', 'tex', 'asciidoc', 'norg' },
                }),
                null_ls.builtins.diagnostics.hadolint,
                null_ls.builtins.diagnostics.ktlint,
                null_ls.builtins.diagnostics.ltrs.with({
                    args = {
                        'check',
                        '-m',
                        '-r',
                        '--split-pattern',
                        '\n',
                        '--max-suggestions',
                        '-1',
                        '--text',
                        '$TEXT',
                    },
                }),
                null_ls.builtins.diagnostics.selene,
                null_ls.builtins.diagnostics.cppcheck,
                null_ls.builtins.diagnostics.write_good,
                null_ls.builtins.diagnostics.markdownlint,
                null_ls.builtins.diagnostics.pylint,
                null_ls.builtins.diagnostics.yamllint,
                null_ls.builtins.diagnostics.vale.with({
                    -- filetypes = {},
                    diagnostics_postprocess = function(diagnostic)
                        -- reduce the severity
                        if diagnostic.severity == vim.diagnostic.severity['ERROR'] then
                            diagnostic.severity = vim.diagnostic.severity['WARN']
                        elseif diagnostic.severity == vim.diagnostic.severity['WARN'] then
                            diagnostic.severity = vim.diagnostic.severity['INFO']
                        end
                    end,
                }),
                null_ls.builtins.code_actions.gitsigns,
                null_ls.builtins.code_actions.refactoring.with({
                    filetypes = { 'go', 'javascript', 'lua', 'python', 'typescript', 'ruby', 'java', 'php' },
                }),
                null_ls.builtins.hover.dictionary,
            },
            on_attach = on_attach,
        })
    end,
}
