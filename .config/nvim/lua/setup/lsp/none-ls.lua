return {
    setup = function(on_attach)
        require('refactoring').setup({})
        local none_ls = require('null-ls')
        none_ls.setup({
            sources = {
                none_ls.builtins.formatting.black,
                none_ls.builtins.formatting.clang_format,
                none_ls.builtins.formatting.cmake_format,
                none_ls.builtins.formatting.prettier,
                none_ls.builtins.formatting.fish_indent,
                none_ls.builtins.formatting.gofmt,
                none_ls.builtins.formatting.goimports,
                none_ls.builtins.formatting.ktlint,
                none_ls.builtins.formatting.markdownlint,
                none_ls.builtins.formatting.shfmt,
                none_ls.builtins.formatting.stylua.with({
                    extra_args = { '--config-path', vim.fn.expand('~/.config/stylua.toml') },
                }),
                none_ls.builtins.diagnostics.actionlint,
                none_ls.builtins.diagnostics.codespell.with({
                    filetypes = { 'markdown', 'tex', 'asciidoc', 'norg' },
                }),
                none_ls.builtins.diagnostics.hadolint,
                none_ls.builtins.diagnostics.ktlint,
                none_ls.builtins.diagnostics.ltrs.with({
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
                none_ls.builtins.diagnostics.selene,
                none_ls.builtins.diagnostics.cppcheck,
                none_ls.builtins.diagnostics.write_good,
                none_ls.builtins.diagnostics.markdownlint,
                none_ls.builtins.diagnostics.pylint,
                none_ls.builtins.diagnostics.yamllint,
                none_ls.builtins.diagnostics.vale.with({
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
                none_ls.builtins.code_actions.gitsigns,
                none_ls.builtins.code_actions.refactoring.with({
                    filetypes = { 'go', 'javascript', 'lua', 'python', 'typescript', 'ruby', 'java', 'php' },
                }),
                none_ls.builtins.hover.dictionary,
            },
            on_attach = on_attach,
        })
    end,
}
