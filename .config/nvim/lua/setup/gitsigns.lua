return {
    setup = function()
        require('gitsigns').setup({
            signcolumn = true,
            numhl = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'right_align',
                ignore_whitespace = true,
            },
            preview_config = {
                border = 'none',
            },
        })
    end,
}
