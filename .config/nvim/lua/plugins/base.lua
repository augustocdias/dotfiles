return {
    -- common utilities
    {
        'ciaranm/securemodelines',
        enabled = not vim.g.vscode,
    }, -- https://vim.fandom.com/wiki/Modeline_magic
    {
        'farmergreg/vim-lastplace',
        enabled = not vim.g.vscode,
    }, -- remembers cursor position with nice features in comparison to just an autocmd
    'nvim-lua/plenary.nvim', -- serveral lua utilities
    {
        'kyazdani42/nvim-web-devicons',
        config = function()
            require('nvim-web-devicons').setup()
        end,
    }, -- icon support for several plugins
    'tpope/vim-repeat', -- adds repeat functionality for other plugins
    {
        'augustocdias/gatekeeper.nvim',
        config = require('setup.gatekeeper').setup,
    }, -- sets buffers outside the cwd as readonly
}
