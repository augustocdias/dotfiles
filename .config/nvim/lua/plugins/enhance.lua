return {
    definitions = function(use)
        use({
            'folke/which-key.nvim',
            config = function()
                local keymaps = require('setup.keymaps')
                keymaps.map_keys()
                require('setup.which-key').setup(keymaps.which_key)
            end,
        }) -- shows the keybindings in a floating window.
        use({ 'andymass/vim-matchup', config = require('setup.matchup').setup }) -- Enhances the % and matches for blocks
        use({ 'numToStr/Comment.nvim', config = require('setup.comment').setup }) -- gcc to comment/uncomment line
        use({ 'kylechui/nvim-surround', config = require('setup.surround').setup }) -- add surround commands
        use({ 'ggandor/leap.nvim', config = require('leap').set_default_keymaps }) -- hop to different parts of the buffer with s + character
        use({
            'booperlv/nvim-gomove',
            config = function()
                require('gomove').setup()
            end,
        }) -- makes better line moving
        use({
            'nvim-pack/nvim-spectre',
            config = function()
                require('spectre').setup()
            end,
        }) -- special search and replace buffer
    end,
}
