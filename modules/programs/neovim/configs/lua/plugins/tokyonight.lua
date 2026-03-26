return {
    'tokyonight',
    colorscheme = 'tokyonight',
    after = function()
        require('tokyonight').setup({
            style = vim.g.flavours.tokyonight,
            -- transparent = true,
            styles = {
                comments = { italic = true },
                conditionals = { italic = true },
                keywords = { italic = true },
            },
            on_colors = function(colors)
                local ucolors = require('tokyonight.util')
                colors.c_float_prompt = ucolors.darken(colors.bg, 0.95)
                colors.c_float_prompt_title = colors.blue0
                colors.c_noice_mini_bg = ucolors.lighten(colors.bg, 0.9)
                colors.c_mini_modified_bg = ucolors.lighten(colors.blue7, 0.3)
            end,
            on_highlights = function(hl, colors)
                hl.FloatBorder = { bg = hl.FloatBorder.bg, fg = hl.FloatBorder.bg }
                hl.NoiceCmdlinePopup = { bg = colors.c_noice_mini_bg }
                hl.NoiceMini = { bg = colors.c_noice_mini_bg }
                hl.MiniFilesBorder = { bg = colors.c_noice_mini_bg, fg = colors.c_noice_mini_bg }
                hl.MiniFilesBorderModified = { bg = colors.c_mini_modified_bg, fg = colors.c_mini_modified_bg }
                hl.MiniFilesNormal = { bg = colors.c_noice_mini_bg }
                hl.MiniFilesModified = { bg = colors.c_mini_modified_bg }
                hl.MiniFilesTitle = { fg = colors.fg, bg = colors.c_float_prompt_title }
                hl.MiniFilesTitleFocused = { fg = colors.fg, bg = colors.c_float_prompt_title }
                hl.MiniFilesCursorLine = { bg = colors.yellow, fg = colors.bg, sp = colors.bg }
                hl.NoiceConfirmBorder = { fg = colors.c_float_prompt, bg = colors.c_float_prompt }
                hl.NoiceFormatConfirm = { fg = colors.c_float_prompt, bg = colors.c_float_prompt_title }
                hl.NoiceFormatConfirmDefault = { fg = colors.c_float_prompt, bg = colors.c_float_prompt_title }
                hl.NoiceConfirm = { bg = colors.c_float_prompt }
                hl.SnacksInputNormal = { bg = colors.c_noice_mini_bg }
                hl.SnacksInputBorder = { bg = colors.c_noice_mini_bg, fg = colors.c_noice_mini_bg }
                hl.DapSign = { fg = colors.yellow }
                hl.DapLineStopped = { bg = colors.c_noice_mini_bg }
                -- dims the text so that the hits are more visible
                hl.LeapBackdrop = { fg = colors.yellow }
            end,
        })
    end,
}
