return {
    -- common utilities
    {
        'securemodelines',
        lazy = false,
    }, -- https://vim.fandom.com/wiki/Modeline_magic
    {
        'nvim-web-devicons',
        on_require = 'nvim-web-devicons',
        after = function()
            require('nvim-web-devicons').setup()
        end,
    }, -- icon support for several plugins
    {
        'plenary',
        on_require = 'plenary',
    }, --  utilities and dependency of many plugins
}
