return {
    setup = function()
        local aerial = require('aerial')

        aerial.setup({
            layout = {
                width = 30,
                default_direction = 'prefer_right',
                placement = 'window',
            },
        })
    end,
}
