-- selene: allow(mixed_table)
return {
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            local keymaps = require('setup.keymaps')
            keymaps.map_keys()
            require('setup.which-key').setup()
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
        'abecodes/tabout.nvim',
        lazy = false,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'L3MON4D3/LuaSnip',
        },
        event = 'InsertCharPre',
        config = require('setup.tabout').setup,
    }, -- improves tab on insert mode
    {
        'folke/flash.nvim',
        event = 'VeryLazy',
        config = require('setup.flash').setup,
    }, -- hop to different parts of the buffer with s + character
    {
        'booperlv/nvim-gomove',
        event = 'VeryLazy',
        config = true,
    }, -- makes better line moving
    {
        'nvim-pack/nvim-spectre',
        enabled = not vim.g.vscode,
        cmd = 'Spectre',
        config = true,
    }, -- special search and replace buffer
    {
        'echasnovski/mini.ai',
        version = false,
        config = true,
    }, -- improves a and i motions
    { 'samjwill/nvim-unception', enabled = not vim.g.vscode }, -- prevents an instance of neovim to be openend within neovim
    { 'chrishrb/gx.nvim', submodules = false, config = require('setup.gx').setup }, -- gx opens urls, github issues etc in the browser
    {
        'jiaoshijie/undotree',
        dependencies = 'nvim-lua/plenary.nvim',
        enabled = not vim.g.vscode,
        event = 'VeryLazy',
        config = true,
    }, -- shows undo history in a window
    {
        'nvim-neorg/neorg',
        ft = 'norg',
        build = ':Neorg sync-parsers',
        config = require('setup.neorg').setup,
        dependencies = {
            'nvim-neotest/nvim-nio',
            'nvim-neorg/lua-utils.nvim',
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            'pysan3/pathlib.nvim',
            'benlubas/neorg-interim-ls',
        },
    },
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        config = require('setup.snacks').setup,
    },
}
