return {
    setup = function()
        require('flash').setup({
            search = {
                -- search/jump in all windows
                multi_window = false,
            },
            char = {
                -- hide after jump when not using jump labels
                autohide = true,
                jump_labels = false,
            },
        })
    end,
}
