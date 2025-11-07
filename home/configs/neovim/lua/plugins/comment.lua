-- gcc to comment/uncomment line

return {
    'comment',
    event = 'DeferredUIEnter',
    after = function()
        require('Comment').setup({
            ignore = '^$',
        })
    end,
}
