return {
    setup = function()
        require('nvim-navic').setup({
            icons = {
                File = ' ',
                Module = ' ',
                Namespace = ' ',
                Package = ' ',
                Class = ' ',
                Method = ' ',
                Property = ' ',
                Field = ' ',
                Constructor = ' ',
                Enum = ' ',
                Interface = ' ',
                Function = ' ',
                Variable = ' ',
                Constant = ' ',
                String = ' ',
                Number = ' ',
                Boolean = ' ',
                Array = ' ',
                Object = ' ',
                Key = ' ',
                Null = ' ',
                EnumMember = ' ',
                Struct = ' ',
                Event = ' ',
                Operator = ' ',
                TypeParameter = ' ',
            },
            -- icons = {
            --     File = ' ',
            --     Module = ' ',
            --     Namespace = ' ',
            --     Package = ' ',
            --     Class = ' ',
            --     Method = ' ',
            --     Property = ' ',
            --     Field = ' ',
            --     Constructor = ' ',
            --     Enum = '練',
            --     Interface = '練',
            --     Function = ' ',
            --     Variable = ' ',
            --     Constant = ' ',
            --     String = ' ',
            --     Number = ' ',
            --     Boolean = '◩ ',
            --     Array = ' ',
            --     Object = ' ',
            --     Key = ' ',
            --     Null = 'ﳠ ',
            --     EnumMember = ' ',
            --     Struct = ' ',
            --     Event = ' ',
            --     Operator = ' ',
            --     TypeParameter = ' ',
            -- },
            highlight = true,
        })
    end,
    winbar = function()
        local eval_navic = function()
            local navic = require('nvim-navic')
            if navic.is_available() then
                return navic.get_location()
            end
        end
        local icon = require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'), nil, { default = true })
        local sig = require('setup.lsp_signature').winbar()
        if sig == nil or sig.label == nil or sig.range == nil then
            return '%#WinBar#' .. icon .. ' ' .. eval_navic() .. '%*'
        end
        local label1 = sig.label
        local label2 = ''
        if sig.range then
            label1 = sig.label:sub(1, sig.range['start'] - 1)
            label2 = sig.label:sub(sig.range['end'] + 1, #sig.label)
        end

        return icon
            .. eval_navic()
            .. '%#WinBarSignature# Signature: '
            .. label1
            .. '%*'
            .. '%#WinBarSigActParm#'
            .. sig.hint
            .. '%*'
            .. '%#WinBarSignature#'
            .. label2
            .. '%*'
    end,
}
