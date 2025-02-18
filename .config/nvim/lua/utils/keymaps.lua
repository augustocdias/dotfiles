local keymap_table = {
    {
        shortcut = 'k',
        cmd = "v:count == 0 ? 'gk' : 'k'",
        mode = { 'n' },
        desc = 'gk if no v:count',
        opts = { noremap = true, silent = true, expr = true },
    },
    {
        shortcut = 'j',
        cmd = "v:count == 0 ? 'gj' : 'j'",
        mode = { 'n' },
        desc = 'gj if no v:count',
        opts = { noremap = true, silent = true, expr = true },
    },
    {
        shortcut = '+',
        cmd = '<C-a>',
        mode = { 'n' },
        desc = 'Increment number',
        opts = { noremap = true },
    },
    {
        shortcut = '-',
        cmd = '<C-x>',
        mode = { 'n' },
        desc = 'Decrement number',
        opts = { noremap = true },
    },
    {
        shortcut = '<C-a>',
        cmd = 'gg<S-v>G',
        mode = { 'n' },
        desc = 'Select all',
        opts = {},
    },
    {
        shortcut = '<M-r>',
        cmd = ':e!<CR>',
        mode = { 'n' },
        desc = 'Refresh buffer',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = 'n',
        cmd = 'nzz',
        mode = { 'n' },
        desc = 'Center search navigation',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = 'p',
        cmd = '<Cmd>silent! normal! "_dP<CR>',
        mode = { 'x' },
        desc = "Smarter Paste in Visual (won't yank deleted content)",
        opts = { noremap = true },
    },
    {
        shortcut = 'dd',
        cmd = function()
            if vim.api.nvim_get_current_line():match('^%s*$') then
                return '"_dd'
            else
                return 'dd'
            end
        end,
        mode = { 'n' },
        desc = "Smarter DD (empty lines won't be yanked)",
        opts = { noremap = true, silent = true, expr = true },
    },
    {
        shortcut = 'N',
        cmd = 'Nzz',
        mode = { 'n' },
        desc = 'Center search navigation',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = '*',
        cmd = '*zz',
        mode = { 'n' },
        desc = 'Center search navigation',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = '#',
        cmd = '#zz',
        mode = { 'n' },
        desc = 'Center search navigation',
        opts = { silent = true, noremap = true },
    },
    {
        shortcut = 'g*',
        cmd = 'g*zz',
        mode = { 'n' },
        desc = 'Center search navigation',
        opts = { silent = true, noremap = true },
    },
    {
        shortcut = '?',
        cmd = '?\\v',
        mode = { 'n' },
        desc = 'Improve search',
        opts = { noremap = true },
    },
    {
        shortcut = '/',
        cmd = '/\\v',
        mode = { 'n' },
        desc = 'Improve search',
        opts = { noremap = true },
    },
    {
        shortcut = '\\',
        cmd = '/@',
        mode = { 'n' },
        desc = 'Improve search',
        opts = { noremap = true },
    },
    {
        shortcut = '%s/',
        cmd = '%sm/',
        mode = { 'c' },
        desc = 'Improve search',
        opts = { noremap = true },
    },
    {
        shortcut = '<M><left>',
        cmd = function()
            require('utils.apple').music:previous_track()
        end,
        mode = { 'n' },
        desc = 'Previous Song (Apple Music)',
        opts = { noremap = true },
    },
    {
        shortcut = '<M><right>',
        cmd = function()
            require('utils.apple').music:next_track()
        end,
        mode = { 'n' },
        desc = 'Next Song (Apple Music)',
        opts = { noremap = true },
    },
    {
        shortcut = '<M-/>',
        cmd = function()
            require('utils.apple').music:play_pause()
        end,
        mode = { 'n' },
        desc = 'Play/Pause (Apple Music)',
        opts = { noremap = true },
    },
    {
        shortcut = '<M-g>',
        cmd = ':nohlsearch<CR>',
        mode = { 'n', 'v' },
        desc = 'Clear search',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = 'H',
        cmd = '^',
        mode = { 'n', 'v' },
        desc = 'Jump to start of the line',
        opts = {},
    },
    {
        shortcut = 'L',
        cmd = '$',
        mode = { 'n', 'v' },
        desc = 'Jump to end of the line',
        opts = {},
    },
    {
        shortcut = '<C-h>',
        cmd = '<Left>',
        mode = { 'i', 'c' },
        desc = 'Move cursor left',
        opts = { noremap = true },
    },
    {
        shortcut = '<C-j>',
        cmd = '<Down>',
        mode = { 'i', 'c' },
        desc = 'Move cursor down',
        opts = { noremap = true },
    },
    {
        shortcut = '<C-k>',
        cmd = '<Up>',
        mode = { 'i', 'c' },
        desc = 'Move cursor up',
        opts = { noremap = true },
    },
    {
        shortcut = '<C-l>',
        cmd = '<Right>',
        mode = { 'i', 'c' },
        desc = 'Move cursor right',
        opts = { noremap = true },
    },
    {
        shortcut = '<right>',
        cmd = '<CMD>vertical resize +2<CR>',
        mode = { 'n' },
        desc = 'Increase window width',
        opts = { noremap = true },
    },
    {
        shortcut = '<left>',
        cmd = '<CMD>vertical resize -2<CR>',
        mode = { 'n' },
        desc = 'Decrease window width',
        opts = { noremap = true },
    },
    {
        shortcut = '<up>',
        cmd = '<CMD>resize +2<CR>',
        mode = { 'n' },
        desc = 'Increase window height',
        opts = { noremap = true },
    },
    {
        shortcut = '<down>',
        cmd = '<CMD>resize -2<CR>',
        mode = { 'n' },
        desc = 'Decrease window height',
        opts = { noremap = true },
    },
    {
        shortcut = '<C-d>',
        cmd = '<C-o>x',
        mode = { 'i' },
        desc = 'Delete char forward in insert mode',
        opts = { noremap = true },
    },
    {
        shortcut = '<C-s>',
        cmd = ':wa<CR>',
        mode = { 'n' },
        desc = 'Savel all',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = '[g',
        cmd = vim.diagnostic.goto_prev,
        mode = { 'n' },
        desc = 'Go to previous diagnostic',
        opts = { noremap = true },
    },
    {
        shortcut = ']g',
        cmd = vim.diagnostic.goto_next,
        mode = { 'n' },
        desc = 'Go to next diagnostic',
        opts = { noremap = true },
    },
    -- call twice make the cursor go into the float window. good for navigating big docs
    {
        shortcut = '<leader>ml',
        cmd = function()
            require('setup.apple').music:playlists()
        end,
        mode = { 'n' },
        desc = 'Playlists',
        opts = { noremap = true },
    },
    {
        shortcut = '<leader>mp',
        cmd = function()
            require('setup.apple').music:play_pause()
        end,
        mode = { 'n' },
        desc = 'Play/Pause',
        opts = { noremap = true },
    },
    {
        shortcut = '<leader>mn',
        cmd = function()
            require('setup.apple').music:next_track()
        end,
        mode = { 'n' },
        desc = 'Next Track',
        opts = { noremap = true },
    },
    {
        shortcut = '<leader>mr',
        cmd = function()
            require('setup.apple').music:previous_track()
        end,
        mode = { 'n' },
        desc = 'Previous Track',
        opts = { noremap = true },
    },
    {
        shortcut = '<leader>c',
        cmd = '"*y',
        mode = { 'v' },
        desc = 'Copy selection to system clipboard',
        opts = { noremap = true },
    },
    {
        shortcut = '<C-h>',
        cmd = function()
            if os.getenv('ZELLIJ') then
                require('zellij-nav').left_tab()
            else
                vim.cmd.wincmd('h')
            end
        end,
        mode = { 'n' },
        desc = 'Focus on window to the left',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = '<C-l>',
        cmd = function()
            print(os.getenv('ZELLIJ'))
            if os.getenv('ZELLIJ') then
                require('zellij-nav').right_tab()
            else
                vim.cmd.wincmd('l')
            end
        end,
        mode = { 'n' },
        desc = 'Focus on window to the right',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = '<C-k>',
        cmd = function()
            if os.getenv('ZELLIJ') then
                require('zellij-nav').up()
            else
                vim.cmd.wincmd('k')
            end
        end,
        mode = { 'n' },
        desc = 'Focus on window up',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = '<C-j>',
        cmd = function()
            if os.getenv('ZELLIJ') then
                require('zellij-nav').down()
            else
                vim.cmd.wincmd('j')
            end
        end,
        mode = { 'n' },
        desc = 'Focus on window down',
        opts = { noremap = true, silent = true },
    },
    {
        shortcut = '<C-m>',
        cmd = function()
            local bufnr = vim.api.nvim_get_current_buf()
            local cur_line = vim.fn.line('.')
            local all_marks_local = vim.fn.getmarklist(bufnr)
            for _, mark in ipairs(all_marks_local) do
                if mark.pos[2] == cur_line and string.match(mark.mark, "'[a-z]") then
                    vim.notify('Deleting mark: ' .. string.sub(mark.mark, 2, 2))
                    vim.api.nvim_buf_del_mark(bufnr, string.sub(mark.mark, 2, 2))
                end
            end
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local all_marks_global = vim.fn.getmarklist()
            for _, mark in ipairs(all_marks_global) do
                local expanded_file_name = vim.fn.fnamemodify(mark.file, ':p')
                if bufname == expanded_file_name and mark.pos[2] == cur_line and string.match(mark.mark, "'[A-Z]") then
                    vim.notify('Deleting mark: ' .. string.sub(mark.mark, 2, 2))
                    vim.api.nvim_del_mark(string.sub(mark.mark, 2, 2))
                end
            end
        end,
        mode = { 'n' },
        desc = 'Delete all marks under the current line',
        opts = { noremap = true, silent = true },
    },
}

return {
    map_keys = function()
        for _, keymap in pairs(keymap_table) do
            local opts = vim.tbl_extend('force', { desc = keymap.desc }, keymap.opts)
            vim.keymap.set(keymap.mode, keymap.shortcut, keymap.cmd, opts)
        end
    end,
}
