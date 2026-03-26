-- improves tab on insert mode

return {
    'tabout',
    event = 'InsertCharPre',
    after = function()
        require('tabout').setup({
        act_as_shift_tab = true,
        act_as_tab = true,
        ignore_beginning = false,
        tabouts = {
            { open = "'", close = "'" },
            { open = '"', close = '"' },
            { open = '`', close = '`' },
            { open = '(', close = ')' },
            { open = '[', close = ']' },
            { open = '{', close = '}' },
            { open = '<', close = '>' },
        },
    })end,
}
