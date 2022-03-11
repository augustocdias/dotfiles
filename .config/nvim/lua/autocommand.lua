-- ensure packer is installed
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost plugins.lua source <afile> | PackerSync
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

-- show box with diagnostics
vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float({focusable=false})]])

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

-- Highlight yanked text
vim.api.nvim_command(
    [[autocmd TextYankPost * lua require'vim.highlight'.on_yank({ higroup = 'IncSearch', timeout = 1000 })]]
)

-- Auto close NvimTree when a file is opened
vim.api.nvim_command(
    [[autocmd BufWipeout NvimTree_* lua vim.schedule(function() require('bufferline.state').set_offset(0) end)]]
)

function leave_snippet()
    if
        ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
        and require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()]
        and not require('luasnip').session.jump_active
    then
        require('luasnip').unlink_current()
    end
end

-- stop snippets when you leave to normal mode
vim.api.nvim_command([[
    autocmd ModeChanged * lua leave_snippet()
]])
