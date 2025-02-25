local wezterm = require('wezterm')
local tabline = wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')

local theme = 'Tokyo Night'

local font_features = {
    'calt',
    'ss01',
    'ss02',
    'ss03',
    'ss04',
    'ss05',
    'ss06',
    'ss07',
    'ss08',
    'ss09',
    'liga',
}

tabline.setup({
    options = {
        icons_enabled = true,
        theme = theme,
        tabs_enabled = true,
        theme_overrides = {},
        section_separators = {
            left = '',
            right = '',
        },
        component_separators = {
            left = '',
            right = '',
        },
        tab_separators = {
            left = '',
            right = '',
        },
    },
    sections = {
        tabline_a = { 'mode' },
        tabline_b = {},
        tabline_c = {},
        tab_active = {
            'index',
            { 'process', padding = { left = 0, right = 1 } },
            '- ',
            { 'parent',  padding = 0 },
            '/',
            { 'cwd',    padding = { left = 0, right = 1 } },
            { 'zoomed', padding = 0 },
        },
        tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
        tabline_x = { 'ram', 'cpu' },
        tabline_y = { 'datetime' },
        tabline_z = { 'domain' },
    },
    extensions = {},
})

local config = {
    font = wezterm.font_with_fallback({
        {
            family = 'MonaspiceNe Nerd Font',
            harfbuzz_features = font_features,
            weight = 500,
        },
        { family = 'codicon' },
    }),
    font_rules = {
        {
            italic = true,
            font = wezterm.font({
                family = 'MonaspiceRn Nerd Font',
                italic = true,
                harfbuzz_features = font_features,
            }),
        },
    },
    use_cap_height_to_scale_fallback_fonts = true,
    font_size = 12.0,
    freetype_load_target = 'Light',
    freetype_render_target = 'HorizontalLcd',
    color_scheme = theme,
    window_padding = {
        left = '0cell',
        right = '0cell',
        top = '0.1cell',
        bottom = '0cell',
    },
}
tabline.apply_to_config(config)

return config
