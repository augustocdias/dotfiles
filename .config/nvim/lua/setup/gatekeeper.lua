return {
    setup = function()
        require('gatekeeper').setup({
            exclude = { vim.fn.expand('~/.config'), 'oil://' },
        })
    end,
}
