return {
    noice_status_color = function(flavour)
        if vim.g.theme == 'catppuccin' then
            return require('catppuccin.palettes').get_palette(flavour).teal
        else
            return require('tokyonight.colors').setup({ style = flavour }).teal
        end
    end,

    command_status = function(color)
        return {
            function()
                return require('noice').api.status.command.get()
            end,
            cond = function()
                return require('noice').api.status.command.has()
            end,
            color = { fg = color },
        }
    end,
}
