return {
    setup = function()
        require('fidget').setup({
            window = {
                blend = 0,
                relative = 'editor',
            },
            text = {
                spinner = 'dots',
            },
        })
    end,
}
