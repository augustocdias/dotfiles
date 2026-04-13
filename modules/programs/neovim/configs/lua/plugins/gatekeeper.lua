-- sets buffers outside the cwd as readonly

return {
    'gatekeeper',
    event = 'DeferredUIEnter',
    after = function()
        require('gatekeeper').setup({
            exclude = {
                vim.fn.expand('~/nixos/'),
            },
            exclude_regex = { '.*/COMMIT_EDITMSG' },
        })
    end,
}
