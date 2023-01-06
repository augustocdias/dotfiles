return {
    setup = function()
        require('lsp_signature').setup({
            floating_window_above_cur_line = true,
        })
    end,
    status_line = function()
        local sig = require('lsp_signature').status_line()
        return sig.hint
    end,
    winbar = function()
        local columns = vim.api.nvim_get_option('columns')
        return require('lsp_signature').status_line(columns)
    end,
}
