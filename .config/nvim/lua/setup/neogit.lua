return {
    setup = function()
        local neogit = require('neogit')

        neogit.setup({
            integrations = {
                diffview = true,
            },
        })
    end,
}
