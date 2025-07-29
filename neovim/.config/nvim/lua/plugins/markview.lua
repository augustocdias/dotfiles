-- markdown enhancements -- alternative render-markdown

return {
    'OXY2DEV/markview.nvim',
    event = 'VeryLazy',
    priority = 49,
    ft = { 'markdown', 'Avante' },
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    opts = {
        experimental = {
            prefer_nvim = true,
        },
        preview = {
            filetypes = { 'markdown', 'quarto', 'rmd', 'typst', 'Avante' },
            icon_provider = 'devicons',
            -- Avante sets the buffer type to `nofile` and it wouldn't enable for Avante in that case
            ignore_buftypes = {},
            condition = function(buffer)
                local ft, bt = vim.bo[buffer].ft, vim.bo[buffer].bt

                if bt == 'nofile' and ft == 'Avante' then
                    return true
                elseif bt == 'nofile' then
                    return false
                else
                    return true
                end
            end,
        },
    },
}
