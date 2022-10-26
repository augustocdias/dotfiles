local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd('packadd packer.nvim')
    require('plugin')
    require('packer').sync()
end

require('settings.general')
require('settings.gui')
require('settings.neovide')
require('plugins')
require('setup.autocommand').setup()
