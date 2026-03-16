-- file browser. eventually should replace neo-tree
return {
    'mini-files',
    after = function()
        require('mini.files').setup()
    end,
    keys = {
        {
            '<leader>vf',
            ':lua MiniFiles.open()<CR>',
            mode = { 'n' },
            desc = 'Toggle File Manager',
            noremap = true,
        },
    },
}
