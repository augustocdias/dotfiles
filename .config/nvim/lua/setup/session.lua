return {
    setup = function()
        vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal,globals,localoptions'
        require('auto-session').setup({
            auto_create = false,
            auto_restore = true,
            cwd_change_handling = true,
            enabled = true,
            post_cwd_changed_cmds = function()
                require('lualine').refresh()
            end,
            session_lens = {
                previewer = true,
                theme_conf = {
                    border = false,
                },
            },
        })
    end,
}
