local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
    vim.api.nvim_create_augroup(name, { clear = true })
end

-- ensure packer is installed
autocmd({ 'BufWritePost' }, {
    desc = 'Auto update packer plugins once the plugins definition file is changed',
    pattern = 'plugins.lua',
    command = 'source <afile> | PackerSync',
    group = augroup('PackerUserConfig'),
})

local cmp_load_group = augroup('CustomCMPLoad')

autocmd({ 'FileType' }, {
    desc = 'Load auto completion for crates only when a toml file is open',
    pattern = 'toml',
    callback = function()
        require('cmp').setup.buffer({ sources = { { name = 'crates' } } })
    end,
    group = cmp_load_group,
})
autocmd({ 'FileType' }, {
    desc = 'Load auto completion using the buffer only for md files',
    pattern = 'markdown',
    callback = function()
        require('cmp').setup.buffer({ sources = { { name = 'buffer' } } })
    end,
    group = cmp_load_group,
})

autocmd({ 'ModeChanged' }, {
    desc = 'Stop snippets when you leave to normal mode',
    pattern = '*',
    callback = function()
        if
            ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
            and require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()]
            and not require('luasnip').session.jump_active
        then
            require('luasnip').unlink_current()
        end
    end,
})

autocmd({ 'CursorHold', 'CursorHoldI' }, {
    desc = 'Show box with diagnosticis for current line',
    pattern = '*',
    callback = function()
        local gps = require('nvim-gps')
        if gps.is_available() then
            vim.wo.winbar = vim.api.nvim_eval("expand('%:t')") .. ' > ' .. gps.get_location()
        else
            vim.wo.winbar = vim.api.nvim_buf_get_name(0)
        end
        vim.diagnostic.open_float({ focusable = false })
    end,
})

-- TODO: apply this to any file outside the cwd
autocmd({ 'BufRead' }, {
    desc = "Prevent accidental writes to buffers that shouldn't be edited",
    pattern = '*.orig',
    command = 'set readonly',
})

local paste_mode_group = augroup('PasteMode')
autocmd({ 'InsertLeave' }, {
    desc = 'Leave paste mode when leaving insert mode',
    pattern = '*',
    command = 'set nopaste',
    group = paste_mode_group,
})

autocmd({ 'BufRead' }, {
    desc = 'Help markdown filetype detection',
    pattern = '*.md',
    command = 'set filetype=markdown',
})

autocmd({ 'TextYankPost' }, {
    desc = 'Highlight yanked text',
    pattern = '*',
    callback = function()
        require('vim.highlight').on_yank({ higroup = 'IncSearch', timeout = 1000 })
    end,
})

autocmd({ 'BufWipeout' }, {
    desc = 'Auto close NvimTree when a file is opened',
    pattern = 'NvimTree_*',
    callback = function()
        vim.schedule(function()
            require('bufferline.state').set_offset(0)
        end)
    end,
})
