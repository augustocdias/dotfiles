-- sets buffers outside the cwd as readonly

return {
    'augustocdias/gatekeeper.nvim',
    event = 'VeryLazy',
    opts = {
        exclude = {
            vim.fn.expand('~/.config'),
            vim.fn.expand('~/dev/dotfiles/'),
        },
        exclude_regex = { '.*/COMMIT_EDITMSG' },
    },
}
