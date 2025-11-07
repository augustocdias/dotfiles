-- session management
return {
    'auto-session',
    lazy = false,
    before = function()
vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal,globals,localoptions'
    end,
    after = function() 
        require('auto-session').setup({
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
    })end,
}
