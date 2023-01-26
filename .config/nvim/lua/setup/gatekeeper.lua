return {
    setup = function()
        require('gatekeeper').setup({
            exclude = { vim.fn.expand('~/.config'), 'oil://' },
            exclude_regex = { '.*/COMMIT_EDITMSG' },
        })
    end,
}
