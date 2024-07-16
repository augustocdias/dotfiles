return {
    setup = function()
        require('tabout').setup({
            act_as_shift_tab = true,
            act_as_tab = true,
            ignore_beginning = false,
            tabouts = {
                { open = '#', close = ']' },
                { open = "'", close = "'" },
                { open = '"', close = '"' },
                { open = '`', close = '`' },
                { open = '(', close = ')' },
                { open = '[', close = ']' },
                { open = '{', close = '}' },
            },
        })
    end,
}
