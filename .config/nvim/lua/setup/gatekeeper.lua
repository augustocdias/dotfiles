return {
    setup = function()
        require('gatekeeper').setup({
            exclude = {
                vim.fn.expand('~/.config'),
                vim.fn.expand(
                    '~/Users/augusto/Library/Mobile Documents/com~apple~CloudDocs/Documents/notes/projects/nvim.norg/Documents/notes/projects'
                ),
            },
            exclude_regex = { '.*/COMMIT_EDITMSG' },
        })
    end,
}
