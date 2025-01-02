-- selene: allow(mixed_table)
return {
    'saghen/blink.cmp', -- auto completion
    version = '*',
    enabled = not vim.g.vscode,
    event = 'VeryLazy',
    config = require('setup.cmp').setup,
    dependencies = {
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets', -- snippets for many languages
        'chrisgrieser/nvim-scissors', -- snippet editor
        'b0o/schemastore.nvim', -- adds schemas for json lsp
    },
}
