return {
    {
        'folke/which-key.nvim',
        config = function()
            local keymaps = require('setup.keymaps')
            keymaps.map_keys()
            require('setup.which-key').setup(keymaps.which_key)
        end,
    }, -- shows the keybindings in a floating window.
    {
        'andymass/vim-matchup',
        enabled = not vim.g.vscode,
        config = require('setup.matchup').setup,
    }, -- Enhances the % and matches for blocks
    { 'numToStr/Comment.nvim', config = require('setup.comment').setup }, -- gcc to comment/uncomment line
    { 'kylechui/nvim-surround', config = require('setup.surround').setup }, -- add surround commands
    {
        'folke/flash.nvim',
        config = require('setup.flash').setup,
    }, -- hop to different parts of the buffer with s + character
    {
        'booperlv/nvim-gomove',
        config = function()
            require('gomove').setup()
        end,
    }, -- makes better line moving
    {
        'nvim-pack/nvim-spectre',
        enabled = not vim.g.vscode,
        cmd = 'LazySpectre',
        config = function()
            require('spectre').setup()
        end,
    }, -- special search and replace buffer
    {
        'echasnovski/mini.bufremove',
        enabled = not vim.g.vscode,
        version = false,
        config = function()
            require('mini.bufremove').setup()
        end,
    }, -- delete buffer and keep window layout
    { 'samjwill/nvim-unception', enabled = not vim.g.vscode }, -- prevents an instance of neovim to be openend within neovim
    { 'chrishrb/gx.nvim', config = require('setup.gx').setup }, -- gx opens urls, github issues etc in the browser
}
