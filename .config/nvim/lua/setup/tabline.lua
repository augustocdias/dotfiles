return {
    setup = function()
        require('tabby.tabline').use_preset('tab_only', {
            lualine_theme = 'catppuccin',
            nerdfont = true, -- whether use nerdfont
        })
        -- require('scope').setup()
    end,
}
