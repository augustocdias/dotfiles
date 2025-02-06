-- Generates an image from selected text. Needs silicon installed (cargo install silicon)
return {
    'mistricky/codesnap.nvim',
    enabled = false,
    build = 'make',
    event = 'VeryLazy',
    opts = {
        save_path = '~/Pictures',
        has_breadcrumbs = true,
        has_linenumber = true,
        bg_theme = 'grape',
        code_font_family = 'MonaspiceNe Nerd Font',
        watermark = 'github.com/augustocdias',
    },
}
