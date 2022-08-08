return {
    setup = function()
        require('neotest').setup({
            adapters = {
                require('neotest-rust'),
            },
            consumers = {
                overseer = require('neotest.consumers.overseer'),
            },
            icons = {
                running = '省',
                failed = ' ',
                skipped = ' ',
                passed = ' ',
            },
        })
    end,
}
