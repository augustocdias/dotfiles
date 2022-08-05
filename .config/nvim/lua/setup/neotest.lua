return {
    setup = function()
        require('neotest').setup({
            adapters = {
                require('neotest-rust'),
            },
            icons = {
                running = '',
            },
        })
    end,
}
