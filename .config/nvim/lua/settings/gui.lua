vim.o.termguicolors = true
vim.o.guicursor = 'n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor'
-- vim.o.guifont = 'FiraCode Nerd Font,codicon:h12:#e-subpixelantialias'
-- Remove toolbar
-- lua api seems to not be able to access this option
vim.cmd('set guioptions-=T')
vim.o.inccommand = 'nosplit'
-- vim.go.t_Co = '256'
vim.o.background = 'dark'
vim.g.base16colorspace = 256
vim.o.foldenable = false
-- https://github.com/vim/vim/issues/1735#issuecomment-383353563
-- vim.o.lazyredraw = true
-- No more beeps
vim.o.vb = true
-- vim.go.t_vb = ''
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
-- vim.cmd('highlight ExtraWhitespace ctermbg=lightyellow guibg=lightyellow')

vim.cmd('syntax on')
vim.cmd('hi Normal ctermbg=NONE')
