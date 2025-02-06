return {
    noice_status_color = function(flavour)
        return require('catppuccin.palettes').get_palette(flavour).teal
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
