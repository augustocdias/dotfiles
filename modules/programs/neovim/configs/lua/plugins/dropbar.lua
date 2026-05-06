-- breadcumbs
-- FIXME: remove when https://github.com/Bekaboo/dropbar.nvim/issues/279 gets fixed
vim.g.loaded_dropbar = true
return {
    'dropbar',
    event = 'DeferredUIEnter',
    enabled = false,
    after = function()
        require('dropbar').setup()
    end,
    lazy = false,
    keys = {
        {
            '<leader>;',
            function()
                require('dropbar.api').pick()
            end,
            mode = { 'n' },
            desc = 'Pick symbols in winbar',
            silent = true,
        },
        {
            '[;',
            function()
                require('dropbar.api').goto_context_start()
            end,
            mode = { 'n' },
            desc = 'Go to start of current context',
            silent = true,
        },
        {
            '];',
            function()
                require('dropbar.api').select_next_context()
            end,
            mode = { 'n' },
            desc = 'Select next context',
            silent = true,
        },
    },
}
