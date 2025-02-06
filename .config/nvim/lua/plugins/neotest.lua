-- test helpers. runs and show signs of test runs

return {
    'nvim-neotest/neotest',
    enabled = false,
    dependencies = {
        'nvim-neotest/nvim-nio',
        'nvim-lua/plenary.nvim',
    },
    lazy = true,
    cmd = 'Neotest',
    config = function()
	    require('neotest').setup({
        adapters = {
            require('rustaceanvim.neotest'),
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
