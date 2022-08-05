require('packer').startup({
    function(use)
        -- common utilities
        use('lewis6991/impatient.nvim') -- speedup lua module load time
        use('ciaranm/securemodelines') -- https://vim.fandom.com/wiki/Modeline_magic
        use({ 'nathom/filetype.nvim', config = require('setup.filetype').setup }) -- replaces filetype load from vim for a more performant one
        use('farmergreg/vim-lastplace') -- remembers cursor position with nice features in comparison to just an autocmd
        use('wbthomason/packer.nvim') -- package manager
        use('nvim-lua/plenary.nvim') -- serveral lua utilities
        use({
            'kyazdani42/nvim-web-devicons',
            config = function()
                require('nvim-web-devicons').setup()
            end,
        }) -- icon support for several plugins
        use('tpope/vim-repeat') -- adds repeat functionality for other plugins
        use('stevearc/dressing.nvim') -- overrides the default vim input to provide better visuals
        use({
            'augustocdias/gatekeeper.nvim',
            config = function()
                require('setup.gatekeeper').setup()
            end,
        }) -- sets buffers outside the cwd as readonly
        require('plugins.cmp').definitions(use)
        require('plugins.lsp').definitions(use)
        require('plugins.treesitter').definitions(use)
        require('plugins.ui').definitions(use)
        require('plugins.enhance').definitions(use)
        require('plugins.utils').definitions(use)
        require('plugins.dev-utils').definitions(use)
    end,
    config = { max_jobs = 30 },
})
