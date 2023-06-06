return {
    setup = function()
        require('nvim-surround').setup({
            surrounds = {
                ['r'] = { add = { 'r#"', '"#' } },
            },
            keymaps = {
                insert = false,
                insert_line = false,
                normal = 'ma',
                normal_cur = false,
                normal_line = false,
                normal_cur_line = false,
                visual = 'm',
                visual_line = false,
                delete = 'md',
                change = 'mr',
            },
            highlight = {
                duration = 1000,
            },
        })
    end,
}
