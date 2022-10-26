return {
    setup = function()
        require('overseer').setup({
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
        local open = function()
            vim.api.nvim_cmd({
                cmd = 'OverseerOpen!',
            }, {})
        end
        local close = function()
            vim.api.nvim_cmd({
                cmd = 'OverseerClose',
            }, {})
        end
        require('sidebar'):register_sidebar('overseer', open, close)
    end,
}
