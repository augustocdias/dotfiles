-- shows nice tab ui
return {
    'tabby',
    event = 'DeferredUIEnter',
    after = function()
        require('tabby.tabline').use_preset('tab_only', {
            lualine_theme = vim.g.theme,
            nerdfont = true, -- whether use nerdfont
        })
    end,
    keys = {
        {
            '<C-t>',
            ':Tabby jump_to_tab<CR>',
            mode = { 'n' },
            desc = 'Select tab',
            noremap = true,
            silent = true,
        },
    },
}
