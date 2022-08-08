return {
    setup = function()
        require('overseer').setup({
            max_width = 30,
            form = {
                border = 'none',
            },
            confirm = {
                border = 'none',
            },
            task_win = {
                border = 'none',
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
