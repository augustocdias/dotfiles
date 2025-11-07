function get_customizations(flavour)
    local colors = require('catppuccin.palettes').get_palette(flavour)
    local ucolors = require('catppuccin.utils.colors')
    local customizations = {
        ['latte'] = {
            float_prompt = ucolors.lighten(colors.crust, 0.95, '#EEEEEE'),
            float_prompt_title = colors.sky,
            noice_mini_bg = ucolors.darken(colors.flamingo, 0.1, '#EEEEEE'),
            mini_modified_bg = ucolors.darken(colors.flamingo, 0.3, '#EEEEEE'),
            mini_cursor = { bg = ucolors.lighten(colors.mantle, 0.1, '#EEEEEE') },
        },
        ['mocha'] = {
            float_prompt = ucolors.darken(colors.crust, 0.95, '#000000'),
            float_prompt_title = colors.sky,
            noice_mini_bg = ucolors.lighten(colors.flamingo, 0.1, '#000000'),
            mini_modified_bg = ucolors.lighten(colors.flamingo, 0.3, '#000000'),
            mini_cursor = { bg = ucolors.lighten(colors.mantle, 0.1, '#000000') },
        },
    }
    return customizations[flavour]
end

return {
    'catppuccin',
    colorscheme = 'catppuccin',
    after = function()
        local flavour = vim.g.flavours.catppuccin
        local colors = require('catppuccin.palettes').get_palette(flavour)
        local customs = get_customizations(flavour)
        local float_prompt = customs.float_prompt
        local float_prompt_title = customs.float_prompt_title
        local noice_mini_bg = customs.noice_mini_bg
        local mini_modified_bg = customs.mini_modified_bg
        require('catppuccin').setup({
            flavour = flavour,
            dim_inactive = {
                enabled = true,
                shade = 'dark',
                percentage = 0.15,
            },
            transparent_background = false,
            term_colors = true,
            compile = {
                enabled = true,
                path = vim.fn.stdpath('cache') .. '/catppuccin',
            },
            auto_integrations = true,
            styles = {
                comments = { 'italic' },
                conditionals = { 'italic' },
                loops = {},
                functions = {},
                keywords = { 'italic' },
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
            },
            integrations = {
                aerial = true,
                avante = true,
                blink_cmp = true,
                dap = true,
                dap_ui = true,
                diffview = true,
                dropbar = {
                    enabled = true,
                    color_mode = true,
                },
                flash = true,
                gitgutter = true,
                gitsigns = true,
                indent_blankline = {
                    enabled = true,
                    colored_indent_levels = false,
                },
                lsp_trouble = true,
                markdown = true,
                markview = true,
                mason = true,
                mini = {
                    enabled = true,
                },
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { 'italic' },
                        hints = { 'italic' },
                        warnings = { 'italic' },
                        information = { 'italic' },
                    },
                    underlines = {
                        errors = { 'underline' },
                        hints = { 'underline' },
                        warnings = { 'underline' },
                        information = { 'underline' },
                    },
                },
                neogit = true,
                neotest = true,
                noice = true,
                nvim_surround = true,
                octo = true,
                overseer = true,
                render_markdown = true,
                semantic_tokens = true,
                snacks = true,
                treesitter = true,
                treesitter_context = true,
                ufo = true,
                which_key = true,
            },
            highlight_overrides = {
                all = {
                    FloatBorder = { fg = 'NONE' },
                    NoiceCmdlinePopup = { bg = noice_mini_bg },
                    NoiceMini = { bg = colors.mantle },
                    MiniFilesBorder = { bg = noice_mini_bg, fg = noice_mini_bg },
                    MiniFilesBorderModified = { bg = mini_modified_bg, fg = mini_modified_bg },
                    MiniFilesNormal = { bg = noice_mini_bg },
                    MiniFilesModified = { bg = mini_modified_bg },
                    MiniFilesCursorLine = customs.mini_cursor,
                    MiniFilesTitle = { fg = colors.base, bg = float_prompt_title },
                    MiniFilesTitleFocused = { fg = colors.base, bg = float_prompt_title },
                    NoiceConfirmBorder = { fg = float_prompt, bg = float_prompt },
                    NoiceFormatConfirm = { fg = float_prompt, bg = float_prompt_title },
                    NoiceFormatConfirmDefault = { fg = float_prompt, bg = float_prompt_title },
                    NoiceConfirm = { bg = float_prompt },
                    SnacksInputNormal = { bg = noice_mini_bg },
                    SnacksInputBorder = { bg = noice_mini_bg, fg = noice_mini_bg },
                    DapSign = { fg = colors.flamingo },
                    DapLineStopped = { bg = noice_mini_bg },
                    -- dims the text so that the hits are more visible
                    LeapBackdrop = { fg = colors.flamingo },
                },
            },
        })
    end,
}
