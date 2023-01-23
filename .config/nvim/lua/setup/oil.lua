return {
    setup = function()
        require('oil').setup({
            keymaps = {
                ['?'] = 'actions.show_help',
                ['g?'] = false,
                ['<CR>'] = 'actions.select',
                ['<C-s>'] = 'actions.select_vsplit',
                ['<C-h>'] = 'actions.select_split',
                ['<C-p>'] = 'actions.preview',
                ['<C-c>'] = 'actions.close',
                ['<C-l>'] = 'actions.refresh',
                ['-'] = 'actions.parent',
                ['_'] = 'actions.open_cwd',
                ['`'] = 'actions.cd',
                ['~'] = 'actions.tcd',
                ['g.'] = 'actions.toggle_hidden',
            },
            float = {
                border = 'none',
            },
        })
    end,
    open = function()
        require('oil').open_float(vim.fn.getcwd())
    end,
    close = function()
        require('oil').discard_all_changes()
        require('oil').close()
    end,
    save = function()
        require('oil').save()
    end,
    select = function()
        require('oil').select()
    end,
}
