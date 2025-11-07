-- improves a and i motions

return {
    'mini-ai',
    event = 'DeferredUIEnter',
    after = function()
        require('mini.ai').setup()
    end,
}
