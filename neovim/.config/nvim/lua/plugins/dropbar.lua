-- breadcumbs

return {
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    config = true,
    lazy = false,
    keys = {
        {
            '<leader>;',
            function()
                require('dropbar.api').pick()
            end,
            mode = { 'n' },
            desc = 'Pick symbols in winbar',
            silent = true,
        },
        {
            '[;',
            function()
                require('dropbar.api').goto_context_start()
            end,
            mode = { 'n' },
            desc = 'Go to start of current context',
            silent = true,
        },
        {
            '];',
            function()
                require('dropbar.api').select_next_context()
            end,
            mode = { 'n' },
            desc = 'Select next context',
            silent = true,
        },
    },
}
