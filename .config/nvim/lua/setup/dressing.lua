return {
    setup = function()
        require('dressing').setup({
            -- TODO: find a way to remove the border
            input = {
                -- border = 'none',
                -- win_options = {
                --     winhighlight = 'InputDressing',
                -- },
            },
            select = {
                builtin = {
                    border = 'none',
                },
            },
        })
    end,
}
