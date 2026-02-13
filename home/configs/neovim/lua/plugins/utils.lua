return {
    -- common utilities
    {
        'mini-icons',
        after = function()
            require('mini.icons').setup()
            MiniIcons.mock_nvim_web_devicons()
        end,
    }, -- icon support for several plugins
    {
        'plenary',
        on_require = 'plenary',
    }, --  utilities and dependency of many plugins
}
