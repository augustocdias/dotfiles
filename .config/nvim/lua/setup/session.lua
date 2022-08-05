return {
    setup = function(post_restore_hook)
        vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal'
        require('auto-session').setup({
            auto_session_create_enabled = false,
            post_restore_cmds = { post_restore_hook },
        })
        require('session-lens').setup({})
    end,
}
