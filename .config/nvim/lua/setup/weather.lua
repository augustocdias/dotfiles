return {
    setup = function()
        require('weather').setup({
            openweathermap = {
                app_id = {
                    var_name = 'WEATHER_TOKEN',
                },
            },
            weather_icons = require('weather.other_icons').nerd_font,
        })
        require('weather.notify').start(70, 'info')
    end,
    status_line = function()
        return require('weather.lualine').default_c({})
    end,
}
