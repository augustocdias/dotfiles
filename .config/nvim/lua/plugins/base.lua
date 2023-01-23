return {
    -- common utilities
    'lewis6991/impatient.nvim', -- speedup lua module load time
    'ciaranm/securemodelines', -- https://vim.fandom.com/wiki/Modeline_magic
    { 'nathom/filetype.nvim', config = require('setup.filetype').setup }, -- replaces filetype load from vim for a more performant one
    'farmergreg/vim-lastplace', -- remembers cursor position with nice features in comparison to just an autocmd
    'nvim-lua/plenary.nvim', -- serveral lua utilities
    {
        'kyazdani42/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup()
        end,
    }, -- icon support for several plugins
    'MunifTanjim/nui.nvim', -- base ui components for nvim
    'tpope/vim-repeat', -- adds repeat functionality for other plugins
    'stevearc/dressing.nvim', -- overrides the default vim input to provide better visuals
    {
        'augustocdias/gatekeeper.nvim',
        config = require('setup.gatekeeper').setup,
    }, -- sets buffers outside the cwd as readonly
}
