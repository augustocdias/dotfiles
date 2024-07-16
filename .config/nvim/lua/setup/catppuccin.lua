return {
    pallete = function(flavour)
        return require('catppuccin.palettes').get_palette(flavour)
    end,
    setup = function(flavour)
        local colors = require('catppuccin.palettes').get_palette(flavour)
        local ucolors = require('catppuccin.utils.colors')
        local telescope_prompt = ucolors.darken(colors.crust, 0.95, '#000000')
        local telescope_results = ucolors.darken(colors.mantle, 0.95, '#000000')
        local telescope_text = colors.text
        local telescope_prompt_title = colors.sky
        local telescope_preview_title = colors.teal
        local lualine_bg = colors.mantle
        local noice_mini_bg = ucolors.lighten(colors.flamingo, 0.1, '#FFFFFF')
        local mini_modified_bg = ucolors.lighten(colors.flamingo, 0.3, '#FFFFFF')
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
                barbar = true,
                cmp = true,
                dap = {
                    enabled = true,
                    enable_ui = true,
                },
                dashboard = true,
                fidget = true,
                flash = true,
                gitgutter = true,
                gitsigns = true,
                indent_blankline = {
                    enabled = true,
                    colored_indent_levels = false,
                },
                leap = true,
                lsp_trouble = true,
                markdown = true,
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
                navic = {
                    enabled = true,
                    custom_bg = lualine_bg,
                },
                neogit = true,
                neotest = true,
                neotree = {
                    enabled = true,
                    show_root = true,
                    transparent_panel = false,
                },
                noice = true,
                notify = true,
                octo = true,
                overseer = true,
                symbols_outline = true,
                telescope = true,
                treesitter = true,
                treesitter_context = true,
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
                    MiniFilesCursorLine = { bg = ucolors.lighten(colors.mantle, 0.1, '#FFFFFF') },
                    MiniFilesTitle = { fg = colors.base, bg = telescope_prompt_title },
                    MiniFilesTitleFocused = { fg = colors.base, bg = telescope_prompt_title },
                    NoiceConfirmBorder = { fg = telescope_prompt, bg = telescope_prompt },
                    NoiceFormatConfirm = { fg = telescope_prompt, bg = telescope_prompt_title },
                    NoiceFormatConfirmDefault = { fg = telescope_prompt, bg = telescope_prompt_title },
                    NoiceConfirm = { bg = telescope_prompt },
                    DapSign = { fg = colors.flamingo },
                    DapLineStopped = { bg = noice_mini_bg },
                    WinBar = { bg = lualine_bg },
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
                    NavicIconsFile = { fg = colors.blue, bg = lualine_bg },
                },
            },
        })

        vim.cmd('colorscheme catppuccin')
    end,
}
