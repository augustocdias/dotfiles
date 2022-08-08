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
        local lualine_bg = colors.mantle
        require('catppuccin').setup({
            dim_inactive = {
                enabled = true,
                shade = 'dark',
                percentage = 0.15,
            },
            transparent_background = false,
            term_colors = true,
            compile = {
                -- enabled = true,
                -- path = vim.fn.stdpath('cache') .. '/catppuccin',
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
                overseer = true,
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
            highlight_overrides = {
                all = {
                    WinBarSigActParm = { fg = colors.blue, bg = colors.mantle },
                    WinBarSignature = { fg = colors.flamingo, bg = colors.mantle },
                    -- dims the text so that the hits are more visible
                    -- your configuration
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
                    NavicIconsModule = { fg = colors.blue, bg = lualine_bg },
                    NavicIconsNamespace = { fg = colors.blue, bg = lualine_bg },
                    NavicIconsPackage = { fg = colors.blue, bg = lualine_bg },
                    NavicIconsClass = { fg = colors.yellow, bg = lualine_bg },
                    NavicIconsMethod = { fg = colors.blue, bg = lualine_bg },
                    NavicIconsProperty = { fg = colors.green, bg = lualine_bg },
                    NavicIconsField = { fg = colors.green, bg = lualine_bg },
                    NavicIconsConstructor = { fg = colors.blue, bg = lualine_bg },
                    NavicIconsEnum = { fg = colors.green, bg = lualine_bg },
                    NavicIconsInterface = { fg = colors.yellow, bg = lualine_bg },
                    NavicIconsFunction = { fg = colors.blue, bg = lualine_bg },
                    NavicIconsVariable = { fg = colors.flamingo, bg = lualine_bg },
                    NavicIconsConstant = { fg = colors.peach, bg = lualine_bg },
                    NavicIconsString = { fg = colors.green, bg = lualine_bg },
                    NavicIconsNumber = { fg = colors.peach, bg = lualine_bg },
                    NavicIconsBoolean = { fg = colors.peach, bg = lualine_bg },
                    NavicIconsArray = { fg = colors.peach, bg = lualine_bg },
                    NavicIconsObject = { fg = colors.peach, bg = lualine_bg },
                    NavicIconsKey = { fg = colors.pink, bg = lualine_bg },
                    NavicIconsNull = { fg = colors.peach, bg = lualine_bg },
                    NavicIconsEnumMember = { fg = colors.red, bg = lualine_bg },
                    NavicIconsStruct = { fg = colors.blue, bg = lualine_bg },
                    NavicIconsEvent = { fg = colors.blue, bg = lualine_bg },
                    NavicIconsOperator = { fg = colors.sky, bg = lualine_bg },
                    NavicIconsTypeParameter = { fg = colors.blue, bg = lualine_bg },
                    NavicText = { fg = colors.teal, bg = lualine_bg },
                    NavicSeparator = { fg = colors.text, bg = lualine_bg },
                },
            },
        })

        vim.cmd('colorscheme catppuccin')
    end,
}
