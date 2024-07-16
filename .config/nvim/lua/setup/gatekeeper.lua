return {
    setup = function()
        require('gatekeeper').setup({
            exclude = {
                vim.fn.expand('~/.config'),
                vim.fn.expand('~/Documents/notes/projects'),
            },
            exclude_regex = { '.*/COMMIT_EDITMSG' },
        })
    end,
}
