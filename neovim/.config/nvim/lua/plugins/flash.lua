-- hop to different parts of the buffer with s + character

return {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
        search = {
            -- search/jump in all windows
            multi_window = false,
        },
        modes = {
            char = {
                config = function(opts)
                    -- autohide flash when in operator-pending mode
                    opts.autohide = vim.fn.mode(true):find('no')
                end,
            },
        },
    },
    keys = {
        {
            's',
            function()
                require('flash').jump()
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Flash',
            noremap = true,
        },
        {
            'S',
            function()
                require('flash').treesitter()
            end,
            mode = { 'n', 'x', 'o' },
            desc = 'Flash Treesitter',
            noremap = true,
        },
        {
            'r',
            function()
                require('flash').remote()
            end,
            mode = { 'o' },
            desc = 'Flash Remote',
            noremap = true,
        },
        {
            'R',
            function()
                require('flash').treesitter_search()
            end,
            mode = { 'x', 'o' },
            desc = 'Flash Treesitter Search',
            noremap = true,
        },
    },
}
