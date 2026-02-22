return {
    -- common utilities
    {
        'mini-icons',
        lazy = false,
        after = function()
            require('mini.icons').setup()
            MiniIcons.mock_nvim_web_devicons()
        end,
    }, -- icon support for several plugins
    {
        'plenary',
        on_require = 'plenary',
    }, --  utilities and dependency of many plugins
    {
        'nui',
        on_require = 'nui',
    }, -- ui components library for neovim
}
