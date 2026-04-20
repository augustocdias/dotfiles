-- markdown enhancements

return {
    {
        'markdown-plus',
        ft = { 'markdown' },
        after = function()
            require('markdown-plus').setup()
        end,
    },
    {
        'markview',
        event = 'DeferredUIEnter',
        priority = 59,
        ft = { 'markdown' },
        after = function()
            require('markview').setup({
                experimental = {
                    prefer_nvim = true,
                },
                preview = {
                    filetypes = { 'markdown', 'quarto', 'rmd', 'typst' },
                    icon_provider = 'mini',
                    ignore_buftypes = {},
                },
            })
        end,
    },
}
