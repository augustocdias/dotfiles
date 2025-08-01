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

local pipepath = vim.fn.stdpath('cache') .. '/server.pipe'
if vim.g.godot and not vim.loop.fs_stat(pipepath) then
    vim.fn.serverstart(pipepath)
end

vim.opt.rtp:prepend(lazypath)

vim.g.theme = 'tokyonight'
vim.g.flavours = {
    catppuccin = 'mocha',
    tokyonight = 'night',
}
vim.g.flavour = vim.g.flavours.tokyonight

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
