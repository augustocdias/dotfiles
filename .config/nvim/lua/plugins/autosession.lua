-- session management
vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal,globals,localoptions'
return {
    'rmagatti/auto-session',
    enabled = not vim.g.vscode,
    lazy = false,
    opts = {
        auto_create = false,
        auto_restore = true,
        cwd_change_handling = true,
        enabled = true,
        post_cwd_changed_cmds = function()
            require('lualine').refresh()
        end,
        session_lens = {
            load_on_setup = false,
            previewer = true,
            theme_conf = {
                border = false,
            },
            mappings = {
                delete_session = {},
                alternate_session = {},
                copy_session = {},
            },
        },
    },
    keys = {
        {
            '<M-w>',
            '<cmd>SessionSearch<CR>',
            mode = { 'n' },
            desc = 'Open saved session',
            noremap = true,
            silent = true,
        },
    },
}
