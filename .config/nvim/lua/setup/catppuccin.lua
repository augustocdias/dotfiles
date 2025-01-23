return {
    noice_status_color = function(flavour)
        return require('catppuccin.palettes').get_palette(flavour).teal
    end,
    setup = function(flavour)
        local colors = require('catppuccin.palettes').get_palette(flavour)
        local ucolors = require('catppuccin.utils.colors')
        local telescope_prompt = ucolors.darken(colors.crust, 0.95, '#000000')
        local telescope_results = ucolors.darken(colors.mantle, 0.95, '#000000')
        local telescope_text = colors.text
        local telescope_prompt_title = colors.sky
        local telescope_preview_title = colors.teal
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
                semantic_tokens = true,
                snacks = true,
                telescope = true,
                treesitter = true,
                treesitter_context = true,
                ufo = true,
                which_key = true,
            },
            highlight_overrides = {
                all = {
                    NoiceCmdlinePopup = { bg = noice_mini_bg },
                    NoiceMini = { bg = colors.mantle },
                    MiniFilesBorder = { bg = noice_mini_bg, fg = noice_mini_bg },
                    MiniFilesBorderModified = { bg = mini_modified_bg, fg = mini_modified_bg },
                    MiniFilesNormal = { bg = noice_mini_bg },
                    MiniFilesModified = { bg = mini_modified_bg },
                    MiniFilesCursorLine = { bg = ucolors.lighten(colors.mantle, 0.1, '#000000') },
                    MiniFilesTitle = { fg = colors.base, bg = telescope_prompt_title },
                    MiniFilesTitleFocused = { fg = colors.base, bg = telescope_prompt_title },
                    NoiceConfirmBorder = { fg = telescope_prompt, bg = telescope_prompt },
                    NoiceFormatConfirm = { fg = telescope_prompt, bg = telescope_prompt_title },
                    NoiceFormatConfirmDefault = { fg = telescope_prompt, bg = telescope_prompt_title },
                    NoiceConfirm = { bg = telescope_prompt },
                    InputDressing = { bg = noice_mini_bg },
                    InputDressingBorder = { bg = noice_mini_bg, fg = noice_mini_bg },
                    DapSign = { fg = colors.flamingo },
                    DapLineStopped = { bg = noice_mini_bg },
                    -- dims the text so that the hits are more visible
                    LeapBackdrop = { fg = colors.flamingo },
                    TelescopeBorder = { bg = telescope_results, fg = telescope_results },
                    TelescopePromptBorder = { bg = telescope_prompt, fg = telescope_prompt },
                    TelescopePromptCounter = { fg = telescope_text },
                    TelescopePromptNormal = { fg = telescope_text, bg = telescope_prompt },
                    TelescopePromptPrefix = { fg = telescope_prompt_title, bg = telescope_prompt },
                    TelescopePromptTitle = { fg = telescope_prompt, bg = telescope_prompt_title },
                    TelescopePreviewTitle = { fg = telescope_results, bg = telescope_preview_title },
                    TelescopePreviewBorder = {
                        bg = ucolors.darken(telescope_results, 0.95, '#000000'),
                        fg = ucolors.darken(telescope_results, 0.95, '#000000'),
                    },
                    TelescopePreviewNormal = {
                        bg = ucolors.darken(telescope_results, 0.95, '#000000'),
                        fg = telescope_results,
                    },
                    TelescopeResultsTitle = { fg = telescope_results, bg = telescope_preview_title },
                    TelescopeMatching = { fg = telescope_prompt_title },
                    TelescopeNormal = { bg = telescope_results },
                    TelescopeSelection = { bg = telescope_prompt },
                    TelescopeSelectionCaret = { fg = telescope_text },
                    TelescopeResultsNormal = { bg = telescope_results },
                    TelescopeResultsBorder = { bg = telescope_results, fg = telescope_results },
                },
            },
        })

        vim.cmd('colorscheme catppuccin')
    end,
}
