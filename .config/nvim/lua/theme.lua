require('nvim-web-devicons').setup({ default = true })
-- require('onedark').setup({
--     transparent = true,
--     darkSidebar = true,
--     darkFloat = true,
--     hideInactiveStatusline = true,
--     sidebars = { 'packer', 'terminal', 'toggleterm' },
-- })

require('gitsigns').setup({ signcolumn = false, numhl = true })

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
vim.o.lazyredraw = true
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
vim.cmd('highlight ExtraWhitespace ctermbg=darkcyan guibg=darkcyan')
vim.cmd('match ExtraWhitespace /\\s\\+$\\|\\t/')

vim.cmd('syntax on')
vim.cmd('hi Normal ctermbg=NONE')
vim.cmd('highlight NvimTreeFolderIcon guibg=darkblue')

-- tokio night theme config
vim.g.tokyonight_hide_inactive_statusline = true
vim.g.tokyonight_sidebars = { 'terminal', 'toggleterm', 'packer', 'NvimTree', 'trouble' }
vim.g.tokyonight_transparent = true
vim.g.tokyonight_style = 'night'
vim.g.tokyonight_dark_sidebar = true
vim.g.tokyight_dark_float = true
-- when using onedark, uncomment line 48 and comment this
vim.cmd([[colorscheme tokyonight]])

local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

-- Set header
dashboard.section.header.val = {
    '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
    '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
    '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
    '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
    '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
    '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
}

-- Set menu
dashboard.section.buttons.val = {
    dashboard.button('e', '  > New file', ':ene <BAR> startinsert <CR>'),
    dashboard.button('f', '  > Open Session', '<cmd>lua require("session-lens").search_session()<CR>'),
    dashboard.button('r', '  > Recent', ':Telescope oldfiles<CR>'),
    dashboard.button('s', '  > Settings', ':e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>'),
    dashboard.button('q', '  > Quit NVIM', ':qa<CR>'),
}
dashboard.section.footer.val = require('alpha.fortune')

-- Send config to alpha
alpha.setup(dashboard.opts)
