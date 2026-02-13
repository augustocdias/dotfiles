-- linting engine replacing none-ls diagnostic sources

return {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        local lint = require('lint')

        lint.linters_by_ft = {
            dockerfile = { 'hadolint' },
            lua = { 'selene' },
            markdown = { 'markdownlint', 'write_good', 'codespell' },
            tex = { 'codespell' },
            asciidoc = { 'codespell' },
            norg = { 'codespell' },
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
