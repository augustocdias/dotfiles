return {
    setup = function()
        require('flash').setup({
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
        })
    end,
}
