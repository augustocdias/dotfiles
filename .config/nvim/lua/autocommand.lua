-- ensure packer is installed
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost plugins.lua source <afile> | PackerCompile
    augroup end
]])

-- load auto completion for crates only when a toml file is open
vim.cmd([[
    autocmd FileType toml lua require('cmp').setup.buffer { sources = { { name = 'crates' } } }
]])

-- load auto completion using the buffer only for md files
vim.cmd([[
    autocmd FileType markdown lua require('cmp').setup.buffer { sources = { { name = 'buffer' } } }
]])

-- auto format file on save
vim.cmd([[
    augroup Format
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
    augroup END
]])

-- Prevent accidental writes to buffers that shouldn't be edited
vim.cmd([[
    autocmd BufRead *.orig set readonly
    autocmd BufRead *.pacnew set readonly
]])

-- Leave paste mode when leaving insert mode
vim.cmd([[
    autocmd InsertLeave * set nopaste
]])

-- Jump to last edit position on opening file
-- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
vim.cmd([[
    au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
]])

-- Remember cursor position
vim.cmd([[
    augroup vimrc-remember-cursor-position
        autocmd!
        autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    augroup END
]])

-- Help filetype detection
vim.cmd([[
    autocmd BufRead *.md set filetype=markdown
]])

-- Highlight text at cursor position
vim.api.nvim_command [[autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()]]
vim.api.nvim_command [[autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()]]
vim.api.nvim_command [[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]]
