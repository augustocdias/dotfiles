vim.g.neovide_no_idle = true
vim.g.neovide_input_use_logo = true
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
vim.g.neovide_transparency = 0.95
vim.g.neovide_theme = 'dark'
vim.g.neovide_floating_shadow = false
vim.g.neovide_floating_corner_radius = 0.5
if vim.g.neovide then
    vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
    vim.keymap.set('v', '<D-c>', '"*y')    -- Copy
    vim.keymap.set('n', '<D-v>', '"*p')    -- Paste normal mode
    vim.keymap.set('v', '<D-v>', '"*p')    -- Paste visual mode
    vim.keymap.set('c', '<D-v>', '<C-r>*') -- Paste command mode
    vim.keymap.set('t', '<D-v>', '<C-r>*') -- Paste in terminal mode
    vim.keymap.set('i', '<D-v>', '<C-r>*') -- Paste insert mode
end
