-- add surround commands
return {
    'mini-surround',
    event = 'DeferredUIEnter',
    after = function()
        require('mini.surround').setup({
            mappings = {
                add = '_a',
                delete = '_d',
                replace = '_r',
                find = '_f',
                find_left = '_F',
                highlight = '_h',
                suffix_last = 'l',
                suffix_next = 'n',
            },
            highlight_duration = 1000,
            respect_selection_type = true,
        })
    end,
}
