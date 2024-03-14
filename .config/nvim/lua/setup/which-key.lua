return {
    setup = function(wk_table)
        local which_key = require('which-key')
        which_key.setup({
            icons = {
                breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
                separator = '󰔰', -- symbol used between a key and it's label
                group = '󰊳 ', -- symbol
            },
        })
        which_key.register(wk_table.visual.maps, wk_table.visual.opts)
        which_key.register(wk_table.normal.maps, wk_table.normal.opts)
    end,
}
