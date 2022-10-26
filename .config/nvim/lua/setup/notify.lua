return {
    setup = function()
        require('notify').setup({
            stages = 'fade_in_slide_out',
            background_colour = '#000000',
        })
        -- overrides vim notification method
        vim.notify = require('notify')
    end,
}
