require('nvim-web-devicons').setup({ default = true })
require('gitsigns').setup({ signcolumn = true, numhl = true })
require('diffview').setup({})

vim.o.termguicolors = true
vim.o.guicursor = 'n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor'
vim.o.guifont = 'FiraCode Nerd Font Mono:12'
-- Remove toolbar
-- lua api seems to not be able to access this option
vim.cmd('set guioptions-=T')
vim.o.inccommand = 'nosplit'
vim.go.t_Co = '256'
vim.o.background = 'dark'
vim.g.base16colorspace = 256
vim.o.foldenable = false
-- https://github.com/vim/vim/issues/1735#issuecomment-383353563
-- vim.o.lazyredraw = true
-- No more beeps
vim.o.vb = true
vim.go.t_vb = ''
vim.o.synmaxcol = 500
vim.o.laststatus = 2
-- Relative line numbers
vim.o.relativenumber = true
-- Also show current absolute line
vim.o.number = true
-- Show (partial) command in status line.
vim.o.showcmd = true
-- Enable mouse usage (all modes) in terminals
vim.o.mouse = 'a'

-- Create a new highlight group for unwanted whitespaces or tabs
vim.cmd('highlight ExtraWhitespace ctermbg=lightyellow guibg=lightyellow')
-- Dims the text when using Leap▎
vim.cmd('highlight LeapBackdrop guifg=#777777')

vim.cmd('syntax on')
vim.cmd('hi Normal ctermbg=NONE')

-- tokio night theme config
vim.g.tokyonight_hide_inactive_statusline = false
vim.g.tokyonight_sidebars = { 'terminal', 'toggleterm', 'packer', 'NvimTree', 'Trouble' }
vim.g.tokyonight_transparent = true
vim.g.tokyonight_style = 'night'
vim.g.tokyonight_dark_sidebar = true
vim.g.tokyight_dark_float = true

-- vim.cmd([[colorscheme tokyonight]])

-- Notify
-- local colors = require('tokyonight.colors').setup({})
require('notify').setup({
    stages = 'fade_in_slide_out',
})

vim.g.catppuccin_flavour = 'latte'
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
    transparent_background = true,
    term_colors = true,
    compile = {
        enabled = false,
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
        nvimtree = {
            enabled = true,
            show_root = true,
            transparent_panel = false,
        },
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
    color_overrides = {},
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

-- overrides vim notification method
vim.notify = require('notify')

-- weather config
require('weather').setup({
    openweathermap = {
        app_id = {
            var_name = 'WEATHER_TOKEN',
        },
    },
    weather_icons = require('weather.other_icons').nerd_font,
})
require('weather.notify').start(70, 'info')

-- lsp status progress
require('fidget').setup({
    window = {
        blend = 0,
        relative = 'editor',
    },
    text = {
        spinner = 'dots',
    },
})
