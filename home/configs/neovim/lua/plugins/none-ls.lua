-- can be useful to integrate with non LSP sources like eslint

return {{
        'refactoring', -- provide refactoring actions
        dep_of = 'none-ls',
        after = function()
            require('refactoring').setup({})
        end
},{
    'none-ls',
    event = 'DeferredUIEnter',
    after = function()
        local on_attach = require('utils.lsp').on_attach
        local none_ls = require('null-ls')
        none_ls.setup({
            sources = {
                none_ls.builtins.formatting.alejandra,
                none_ls.builtins.formatting.black,
                none_ls.builtins.formatting.prettier,
                none_ls.builtins.formatting.fish_indent,
                none_ls.builtins.formatting.shfmt,
                none_ls.builtins.formatting.sqlfluff,
                none_ls.builtins.formatting.stylua.with({
                    extra_args = { '--config-path', vim.fn.expand('~/.config/stylua.toml') },
                }),
                none_ls.builtins.diagnostics.actionlint,
                none_ls.builtins.diagnostics.codespell.with({
                    filetypes = { 'markdown', 'tex', 'asciidoc', 'norg' },
                }),
                none_ls.builtins.diagnostics.deadnix,
                none_ls.builtins.diagnostics.hadolint,
                none_ls.builtins.diagnostics.selene,
                none_ls.builtins.diagnostics.write_good,
                none_ls.builtins.diagnostics.yamllint,
                none_ls.builtins.code_actions.gitsigns,
                none_ls.builtins.code_actions.refactoring.with({
                    filetypes = { 'go', 'javascript', 'lua', 'python', 'typescript', 'ruby', 'java', 'php' },
                }),
                none_ls.builtins.code_actions.statix,
                none_ls.builtins.hover.dictionary,
            },
            on_attach = on_attach,
        })
    end,
    keys = {
        {
            '<leader>nI',
            ':Refactor inline_func',
            mode = { 'n' },
            desc = 'Inline Function',
            noremap = true,
        },
        {
            '<leader>nb',
            ':Refactor extract_block',
            mode = { 'n' },
            desc = 'Extract Block',
            noremap = true,
        },
        {
            '<leader>nc',
            '<cmd>lua require("refactoring").debug.cleanup({})<CR>',
            mode = { 'n' },
            desc = 'Cleanup',
            noremap = true,
        },
        {
            '<leader>nf',
            ':Refactor extract_block_to_file',
            mode = { 'n' },
            desc = 'Extract Block to File',
            noremap = true,
        },
        {
            '<leader>ni',
            ':Refactor inline_var',
            mode = { 'n' },
            desc = 'Inline Variable',
            noremap = true,
        },
        {
            '<leader>np',
            '<cmd>lua require("refactoring").debug.printf()<CR>',
            mode = { 'n' },
            desc = 'Printf',
            noremap = true,
        },
        {
            '<leader>nr',
            '<cmd>lua require("refactoring").select_refactor()<CR>',
            mode = { 'n' },
            desc = 'Refactors',
            noremap = true,
        },
        {
            '<leader>nv',
            '<cmd>lua require("refactoring").debug.print_var()<CR>',
            mode = { 'n' },
            desc = 'Print Variable',
            noremap = true,
        },
        {
            '<leader>ne',
            ':Refactor extract',
            mode = { 'v' },
            desc = 'Extract',
            noremap = true,
        },
        {
            '<leader>nf',
            ':Refactor extract_to_file ',
            mode = { 'v' },
            desc = 'Extract to file',
            noremap = true,
        },
        {
            '<leader>ni',
            ':Refactor inline_var',
            mode = { 'v' },
            desc = 'Inline Variable',
            noremap = true,
        },
        {
            '<leader>np',
            '<cmd>lua require("refactoring").debug.print_var()<CR>',
            mode = { 'v' },
            desc = 'Print Variable',
            noremap = true,
        },
        {
            '<leader>nr',
            '<cmd>lua require("refactoring").select_refactor()<CR>',
            mode = { 'v' },
            desc = 'Refactors',
            noremap = true,
        },
        {
            '<leader>nv',
            ':Refactor extract_var ',
            mode = { 'v' },
            desc = 'Extract Variable',
            noremap = true,
        },
    },
}}
