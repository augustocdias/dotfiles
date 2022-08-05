return {
    setup = function()
        require('indent_blankline').setup({
            char = '|',
            filetype_exclude = { 'packer', 'startup' },
            buftype_exclude = { 'terminal' },
        })
    end,
}
