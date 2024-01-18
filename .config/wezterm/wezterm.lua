local wezterm = require('wezterm')
return {
    font = wezterm.font_with_fallback({
        { family = 'FiraCode Nerd Font', harfbuzz_features = { 'zero', 'onum' }, weight = 450 },
        { family = 'codicon' },
    }),
    font_rules = {
        {
            italic = true,
            font = wezterm.font('VictorMono Nerd Font', { italic = true }),
        },
        {
            italic = true,
            intensity = 'Bold',
            font = wezterm.font('VictorMono Nerd Font', { italic = true }),
        },
    },
    use_cap_height_to_scale_fallback_fonts = true,
    font_size = 12.0,
    freetype_load_target = 'Light',
    freetype_render_target = 'HorizontalLcd',
    color_scheme = 'Catppuccin Latte',
}
