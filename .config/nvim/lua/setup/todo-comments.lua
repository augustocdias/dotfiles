return {
    setup = function()
        require('todo-comments').setup({
            signs = false,
            highlight = {
                comments_only = true,
            },
            search = {
                command = 'rg',
                args = {
                    '--max-depth=10',
                    '--color=never',
                    '--no-heading',
                    '--with-filename',
                    '--line-number',
                    '--column',
                },
            },
        })
    end,
}
