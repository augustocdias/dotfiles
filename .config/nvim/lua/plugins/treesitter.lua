return {
    definitions = function(use)
        use({
            'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate',
            config = require('setup.treesitter').setup,
        }) -- enhancements in highlighting and virtual text
        use('nvim-treesitter/nvim-treesitter-textobjects') -- adds treesitter based text objects
        use('nvim-treesitter/playground') -- TS PLayground for creating queries
    end,
}
