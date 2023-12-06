return {
    setup = function()
        require('ibl').setup({
            indent = {
                char = '│',
            },
            exclude = {
                filetypes = { 'packer', 'startup', 'noice' },
                buftypes = { 'terminal' },
            },
            scope = {
                enabled = true,
            },
        })
    end,
}
