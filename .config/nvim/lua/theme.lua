vim.o.termguicolors = true
vim.go.guicursor = 'n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor'
vim.go.inccommand = 'nosplit'
vim.go.t_Co = '256'
vim.o.background = 'dark'
vim.g.base16colorspace = 256
vim.cmd('syntax on')
vim.cmd('hi Normal ctermbg=NONE')
vim.cmd('highlight NvimTreeFolderIcon guibg=blue')

require'nvim-web-devicons'.setup { default = true }
require'onedark'.setup { transparent = true }
require('gitsigns').setup({ signcolumn = false, numhl = true })
