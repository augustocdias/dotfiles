return {
    setup = function()
        require('snacks').setup({
            bigfile = { enabled = true },
            bufdelete = { enabled = true },
            gitbrowse = { enabled = true },
            indent = { enabled = true, only_current = true },
            notifier = { enabled = true, style = 'fancy' },
            rename = { enabled = true },
            words = { enabled = true },
            styles = {
                blame_line = { border = 'none' },
                notification = { border = 'none' },
                notification_history = { border = 'none' },
            },
        })
    end,
}
