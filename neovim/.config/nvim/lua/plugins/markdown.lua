-- markdown enhancements -- check marvkview

return {
    'MeanderingProgrammer/render-markdown.nvim',
    event = 'VeryLazy',
    ft = { 'markdown', 'Avante' },
    dependencies = {
        'nvim-tree/nvim-web-devicons', -- Used by the code bloxks
    },
    opts = {
        file_types = { 'markdown', 'Avante' },
    },
}
