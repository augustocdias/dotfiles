return {
    -- common utilities
    {
        'ciaranm/securemodelines',
        enabled = not vim.g.vscode,
    }, -- https://vim.fandom.com/wiki/Modeline_magic
    {
        'kyazdani42/nvim-web-devicons',
        enabled = not vim.g.vscode,
        config = true,
    }, -- icon support for several plugins
}
