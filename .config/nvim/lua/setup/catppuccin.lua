return {
    setup = function(flavour)
        vim.g.catppuccin_flavour = flavour
        local colors = require('catppuccin.palettes').get_palette()
        local ucolors = require('catppuccin.utils.colors')
        local telescope_prompt = ucolors.darken(colors.crust, 0.95, '#000000')
        local telescope_results = ucolors.darken(colors.mantle, 0.95, '#000000')
        local telescope_text = colors.text
        local telescope_prompt_title = colors.sky
        local telescope_preview_title = colors.teal
        require('catppuccin').setup({
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
                treesitter = true,
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
                lsp_trouble = true,
                cmp = true,
                lsp_saga = true,
                gitgutter = true,
                gitsigns = true,
                leap = true,
                telescope = true,
                navic = true,
                neotree = {
                    enabled = true,
                    show_root = true,
                    transparent_panel = false,
                },
                dap = {
                    enabled = true,
                    enable_ui = true,
                },
                which_key = true,
                indent_blankline = {
                    enabled = true,
                    colored_indent_levels = false,
                },
                dashboard = true,
                neogit = true,
                barbar = true,
                markdown = true,
                notify = true,
                symbols_outline = true,
                aerial = true,
            },
            custom_highlights = {
                WinBarSigActParm = { fg = colors.blue },
                WinBarSignature = { fg = colors.flamingo },
                -- dims the text so that the hits are more visible
                LeapBackdrop = { fg = colors.flamingo },
            },
            highlight_overrides = {
                all = {
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
