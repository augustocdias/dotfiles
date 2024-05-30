return {
    setup = function()
        require('trouble').setup({
            modes = {
                test = {
                    mode = 'diagnostics',
                    preview = {
                        type = 'split',
                        relative = 'win',
                        position = 'right',
                        size = 0.3,
                    },
                },
            },
        })
    end,
}
