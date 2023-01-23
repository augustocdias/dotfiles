return {
    open = function()
        require('sidebar-nvim').open()
    end,
    close = function()
        require('sidebar-nvim').close()
    end,
    setup = function()
        require('sidebar-nvim').setup({
            open = false,
            side = 'left',
            initial_width = 30,
            update_interval = 1000,
            hide_statusline = true,
            sections = { 'files', 'git', 'todos', 'symbols', 'diagnostics', 'containers' },
            todos = {
                ignored_paths = { '~' },
                initially_closed = false,
            },
        })
        local open_sidebar = function()
            require('sidebar-nvim').open()
        end

        local close_sidebar = function()
            require('sidebar-nvim').close()
        end

        require('sidebar'):register_sidebar('sidebar', open_sidebar, close_sidebar)
    end,
}
