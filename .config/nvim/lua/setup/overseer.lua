return {
    setup = function()
        require('overseer').setup({
            direction = 'left',
            task_list = {
                max_width = 30,
                min_width = 30,
            },
            form = {
                border = 'none',
                win_opts = {
                    winblend = 0,
                    winhighlight = 'NormalFloat:Normal',
                },
            },
            confirm = {
                border = 'none',
                win_opts = {
                    winblend = 0,
                    winhighlight = 'NormalFloat:Normal',
                },
            },
            task_win = {
                border = 'none',
                win_opts = {
                    winblend = 0,
                },
            },
            log = {
                type = 'notify',
            },
        })
    end,
}
