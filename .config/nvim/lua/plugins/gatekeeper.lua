-- sets buffers outside the cwd as readonly

return {
    'augustocdias/gatekeeper.nvim',
    opts = {
        exclude = {
            vim.fn.expand('~/.config'),
            vim.fn.expand(
                '~/Library/Mobile Documents/com~apple~CloudDocs/Documents/notes/projects/nvim.norg/Documents/notes/projects'
            ),
        },
        exclude_regex = { '.*/COMMIT_EDITMSG' },
    },
}
