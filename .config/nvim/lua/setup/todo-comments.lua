return {
    setup = function()
        require('todo-comments').setup({
            signs = true,
            keywords = {
                TODO = { alt = { 'todo', 'unimplemented' } },
            },
            highlight = {
                comments_only = false,
                pattern = {
                    [[.*<(KEYWORDS)\s*:]],
                    [[.*<(KEYWORDS)\s*!\(]],
                },
            },
            search = {
                pattern = [[\b(KEYWORDS)(:|!\()]],
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
