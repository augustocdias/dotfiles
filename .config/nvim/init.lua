local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.theme = 'catppuccin'
vim.g.flavour = 'mocha'

require('settings.general')
require('settings.gui')
require('settings.neovide')
require('settings.unception')
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
require('setup.autocommand').setup()

vim.cmd('colorscheme ' .. vim.g.theme)
