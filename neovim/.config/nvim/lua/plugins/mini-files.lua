-- file browser. eventually should replace neo-tree
return {
    'echasnovski/mini.files',
    version = false,
    event = 'VeryLazy',
    config = true,
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
