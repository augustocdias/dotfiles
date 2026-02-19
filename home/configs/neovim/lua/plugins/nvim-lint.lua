-- linters
return {
    'nvim-lint',
    event = { 'BufEnter', 'BufWritePre', 'BufNewFile' },
    after = function()
        local lint = require('lint')

        lint.linters_by_ft = {
            dockerfile = { 'hadolint' },
            javascript = { 'eslint' },
            javascriptreact = { 'eslint' },
            typescript = { 'eslint' },
            typescriptreact = { 'eslint' },
            lua = { 'selene' },
            markdown = { 'markdownlint', 'write_good', 'codespell' },
            nix = { 'statix', 'deadnix' },
            tex = { 'codespell' },
            asciidoc = { 'codespell' },
            yaml = { 'yamllint', 'actionlint' },
        }

        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = vim.api.nvim_create_augroup('NvimLint', { clear = true }),
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
