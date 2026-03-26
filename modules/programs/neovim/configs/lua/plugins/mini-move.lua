-- makes better line moving

return {
    'mini-move',
    event = 'DeferredUIEnter',
    after = function()
        require('mini.move').setup()
    end,
}
