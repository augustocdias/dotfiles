-- highlights todo,fixme,etc. comments

return {
    'todo-comments',
    event = 'DeferredUIEnter',
    after = function()
        require('todo-comments').setup({
        signs = true,
        keywords = {
            TODO = { icon = '', alt = { 'todo', 'unimplemented' } },
            FIX = { icon = '' },
            HACK = { icon = '' },
            WARN = { icon = '' },
            PERF = { icon = '󰾆' },
            NOTE = { icon = '' },
            TEST = { icon = '⏲' },
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
    })end,
}
