-- add surround commands

return {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {
        surrounds = {
            ['r'] = { add = { 'r#"', '"#' } },
        },
        keymaps = {
            insert = false,
            insert_line = false,
            normal = '<leader>sa',
            normal_cur = false,
            normal_line = false,
            normal_cur_line = false,
            visual = '<leader>s',
            visual_line = false,
            delete = '<leader>sd',
            change = '<leader>sr',
        },
        highlight = {
            duration = 1000,
        },
    },
}
