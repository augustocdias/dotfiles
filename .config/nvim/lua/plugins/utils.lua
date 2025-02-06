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
    {
        'kyazdani42/nvim-web-devicons',
        enabled = not vim.g.vscode,
        config = true,
    }, -- icon support for several plugins
    { 'samjwill/nvim-unception', enabled = not vim.g.vscode }, -- prevents an instance of neovim to be openend within neovim
}
