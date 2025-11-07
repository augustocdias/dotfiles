-- file browser. eventually should replace neo-tree
return {
    'mini-files',
    after = function()
        require('mini.files').setup()
    end,
    keys = {
        {
            '<F2>',
            ':lua MiniFiles.open()<CR>',
            mode = { 'n' },
            desc = 'Toggle File Manager',
            noremap = true,
        },
    },
}
