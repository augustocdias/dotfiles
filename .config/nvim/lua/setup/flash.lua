return {
    setup = function()
        require('flash').setup({
            search = {
                -- search/jump in all windows
                multi_window = false,
            },
        })
    end,
}
