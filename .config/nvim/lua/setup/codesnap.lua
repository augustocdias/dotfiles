return {
    setup = function()
        require('codesnap').setup({
            save_path = '~/Pictures',
            has_breadcrumbs = true,
            has_linenumber = true,
            bg_theme = 'grape',
            code_font_family = 'MonaspiceNe Nerd Font',
            watermark = 'augustocdias',
        })
    end,
}
