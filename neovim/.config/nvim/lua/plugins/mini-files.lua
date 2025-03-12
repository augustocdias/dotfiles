-- file browser. eventually should replace neo-tree
return {
    'echasnovski/mini.files',
    version = false,
    event = 'VeryLazy',
    enabled = not vim.g.vscode,
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
