return {
    setup = function()
        require('nvim-navic').setup({
            icons = {
                File = ' ',
                Module = ' ',
                Namespace = ' ',
                Package = ' ',
                Class = ' ',
                Method = '󰊕 ',
                Property = ' ',
                Field = '󰜢 ',
                Constructor = '',
                Enum = ' ',
                Interface = ' ',
                Function = '󰊕 ',
                Variable = ' ',
                Constant = ' ',
                String = ' ',
                Number = ' ',
                Boolean = ' ',
                Array = ' ',
                Object = ' ',
                Key = '󱕴 ',
                Null = ' ',
                EnumMember = ' ',
                Struct = ' ',
                Event = ' ',
                Operator = ' ',
                TypeParameter = ' ',
            },
            highlight = true,
        })
    end,
    winbar = function()
        local eval_navic = function()
            local navic = require('nvim-navic')
            if navic.is_available() then
                local data = navic.get_data()
                return navic.format_data(data)
            end
        end
        local icon = require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'), nil, { default = true })
        return '%#WinBar#' .. icon .. ' ' .. eval_navic() .. '%*'
    end,
}
