local wezterm = require('wezterm')
return {
    font = wezterm.font_with_fallback({
        { family = 'MonaspiceNe Nerd Font', harfbuzz_features = { 'zero', 'onum' }, weight = 450 },
        { family = 'codicon' },
    }),
    font_rules = {
        {
            italic = true,
            font = wezterm.font('MonaspiceRn Nerd Font', { italic = true }),
        },
        {
            italic = true,
            intensity = 'Bold',
            font = wezterm.font('MonaspiceRn Nerd Font', { italic = true, bold = true }),
        },
    },
    use_cap_height_to_scale_fallback_fonts = true,
    use_fancy_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    font_size = 12.0,
    freetype_load_target = 'Light',
    freetype_render_target = 'HorizontalLcd',
    color_scheme = 'Catppuccin Latte',
    window_padding = {
        left = '0cell',
        right = '0cell',
        top = '0.1cell',
        bottom = '0cell',
    },
}
