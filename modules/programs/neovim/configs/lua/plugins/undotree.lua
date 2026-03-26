-- shows undo history in a window
return {
    'undotree',
    event = 'DeferredUIEnter',
    keys = {
        {
            '<leader>u',
            function()
                require('undotree').toggle()
            end,
            mode = { 'n' },
            desc = 'Toggle undotree',
            silent = true,
        },
    },
}
