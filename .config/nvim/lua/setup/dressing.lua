return {
    setup = function()
        require('dressing').setup({
            input = {
                title_pos = 'center',
                win_options = {
                    winhighlight = 'NormalFloat:InputDressing,FloatBorder:InputDressingBorder',
                },
            },
            select = {
                builtin = {
                    border = 'none',
                },
            },
        })
    end,
}
