return {
    setup = function()
        require('notify').setup({
            stages = 'fade_in_slide_out',
        })
        -- overrides vim notification method
        vim.notify = require('notify')
    end,
}
