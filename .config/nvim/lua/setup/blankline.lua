return {
    setup = function()
        require('indent_blankline').setup({
            char = '┆',
            filetype_exclude = { 'packer', 'startup', 'noice' },
            buftype_exclude = { 'terminal' },
            show_current_context = true,
        })
    end,
}
