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

-- highlight all tabs and trailing whitespace characters.
vim.cmd('highlight ExtraWhitespace ctermbg=lightyellow guibg=lightyellow')
vim.cmd('match ExtraWhitespace /\\s\\+$\\|\\t/')

vim.cmd('syntax on')
vim.cmd('hi Normal ctermbg=NONE')
vim.cmd('highlight NvimTreeFolderIcon guibg=blue')

-- tokio night theme config
vim.g.tokyonight_hide_inactive_statusline = false
vim.g.tokyonight_sidebars = { 'terminal', 'toggleterm', 'packer', 'NvimTree', 'Trouble' }
vim.g.tokyonight_transparent = true
vim.g.tokyonight_style = 'night'
vim.g.tokyonight_dark_sidebar = true
vim.g.tokyight_dark_float = true

vim.cmd([[colorscheme tokyonight]])
-- require('colorbuddy').colorscheme('cobalt2')

-- Notify
local colors = require('tokyonight.colors').setup({})
require('notify').setup({
    stages = 'fade_in_slide_out',
    background_colour = colors.bg_dark,
})
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
