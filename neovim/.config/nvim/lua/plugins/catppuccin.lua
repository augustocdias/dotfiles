return {
    'catppuccin/nvim',
    lazy = false,
    priority = 1000,
    config = function()
        local flavour = vim.g.flavours.catppuccin
        local colors = require('catppuccin.palettes').get_palette(flavour)
        local ucolors = require('catppuccin.utils.colors')
        local float_prompt = ucolors.darken(colors.crust, 0.95, '#000000')
        local float_prompt_title = colors.sky
        local noice_mini_bg = ucolors.lighten(colors.flamingo, 0.1, '#000000')
        local mini_modified_bg = ucolors.lighten(colors.flamingo, 0.3, '#000000')
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
                    MiniFilesCursorLine = { bg = ucolors.lighten(colors.mantle, 0.1, '#000000') },
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
