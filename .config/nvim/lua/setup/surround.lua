return {
    setup = function()
        require('nvim-surround').setup({
            surrounds = {
                ['r'] = { add = { 'r#"', '"#' } },
            },
            keymaps = {
                insert = false,
                insert_line = false,
                normal = ',a',
                normal_cur = false,
                normal_line = false,
                normal_cur_line = false,
                visual = ',',
                visual_line = false,
                delete = ',d',
                change = ',r',
            },
            highlight = {
                duration = 1000,
            },
        })
    end,
}
