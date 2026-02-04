-- shows undo history in a window
return {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    event = 'VeryLazy',
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
