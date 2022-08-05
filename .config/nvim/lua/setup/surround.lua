return {
    setup = function()
        require('nvim-surround').setup({
            brackets = { '(', '{', '[', '<' },
            delimiters = {
                pairs = {
                    ['('] = { '(', ')' },
                    [')'] = { '(', ')' },
                    ['{'] = { '{', '}' },
                    ['}'] = { '{', '}' },
                    ['<'] = { '<', '>' },
                    ['>'] = { '<', '>' },
                    ['['] = { '[', ']' },
                    [']'] = { '[', ']' },
                    ['r#"'] = { 'r#"', '"#' },
                },
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
        })
    end,
}
