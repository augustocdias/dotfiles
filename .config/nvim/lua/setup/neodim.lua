return {
    setup = function()
        require('neodim').setup({
            alpha = 0.75,
            blend_color = '#efebc2',
            update_in_insert = {
                enable = true,
                delay = 100,
            },
            hide = {
                virtual_text = true,
                signs = false,
                underline = false,
            },
        })
    end,
}
