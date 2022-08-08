return {
    setup = function()
        vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal'
        require('auto-session').setup({
            auto_session_enabled = true, -- enables auto save and auto restore
            auto_session_create_enabled = false, -- disables auto session creation
            cwd_change_handling = {
                restore_upcoming_session = true,
                pre_cwd_changed_hook = function()
                    require('sidebar'):close()
                end,
                post_cwd_changed_hook = function()
                    require('lualine').refresh()
                end,
            },
        })
        require('session-lens').setup({})
    end,
}
