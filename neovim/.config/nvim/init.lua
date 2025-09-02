local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end

local pipe_suffix
if vim.g.godot then
    pipe_suffix = 'godot'
else
    pipe_suffix = os.getenv('ZELLIJ_SESSION_NAME') or 'dettached'
end

local pipepath = vim.fn.stdpath('cache') .. '/server-' .. pipe_suffix .. '.pipe'
if not vim.uv.fs_stat(pipepath) then
    vim.fn.serverstart(pipepath)
end

vim.opt.rtp:prepend(lazypath)

vim.g.theme = 'catppuccin'
vim.g.flavours = {
    -- catppuccin = 'mocha', -- dark
    catppuccin = 'latte', -- light
    tokyonight = 'day', -- light
    -- tokyonight = 'night', -- dark
}
vim.g.flavour = vim.g.flavours[vim.g.theme]

require('utils.logger').setup()

require('utils.custom_fold')
require('settings.general')
require('settings.gui')
require('settings.neovide')
require('utils.keymaps').map_keys()
require('lazy').setup('plugins', {
    checker = {
        enabled = true,
        frequency = 7200,
    },
    rocks = {
        enabled = false,
    },
})
require('utils.autocommands').setup()

vim.cmd('colorscheme ' .. vim.g.theme)
