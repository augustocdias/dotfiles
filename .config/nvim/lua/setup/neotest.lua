return {
    setup = function()
        require('neotest').setup({
            adapters = {
                require('rustaceanvim.neotest'),
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
