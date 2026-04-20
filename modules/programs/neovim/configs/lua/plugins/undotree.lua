-- shows undo history in a window (builtin neovim plugin)
return {
    'nvim.undotree',
    keys = {
        {
            '<leader>u',
            function()
                require('undotree').open()
            end,
            mode = { 'n' },
            desc = 'Toggle undotree',
            silent = true,
        },
    },
}
