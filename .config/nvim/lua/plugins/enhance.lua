return {
    {
        'folke/which-key.nvim',
        config = function()
            local keymaps = require('setup.keymaps')
            keymaps.map_keys()
            require('setup.which-key').setup(keymaps.which_key)
        end,
    }, -- shows the keybindings in a floating window.
    { 'andymass/vim-matchup', config = require('setup.matchup').setup }, -- Enhances the % and matches for blocks
    { 'numToStr/Comment.nvim', config = require('setup.comment').setup }, -- gcc to comment/uncomment line
    { 'kylechui/nvim-surround', config = require('setup.surround').setup }, -- add surround commands
    {
        'ggandor/leap.nvim',
        config = function()
            require('leap').set_default_keymaps()
        end,
    }, -- hop to different parts of the buffer with s + character
    {
        'booperlv/nvim-gomove',
        config = function()
            require('gomove').setup()
        end,
    }, -- makes better line moving
    {
        'otavioschwanck/cool-substitute.nvim',
        config = require('setup.substitute').setup,
    }, -- kinda multi cursor support
    {
        'nvim-pack/nvim-spectre',
        config = function()
            require('spectre').setup()
        end,
    }, -- special search and replace buffer
    'famiu/bufdelete.nvim', -- delete buffer and keep window layout
    'samjwill/nvim-unception', -- prevents an instance of neovim to be openend within neovim
}
