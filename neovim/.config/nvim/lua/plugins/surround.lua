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
            normal = '_a',
            normal_cur = false,
            normal_line = false,
            normal_cur_line = false,
            visual = '_',
            visual_line = false,
            delete = '_d',
            change = '_r',
        },
        highlight = {
            duration = 1000,
        },
    },
}
