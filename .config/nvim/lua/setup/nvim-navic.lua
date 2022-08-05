local eval_navic = function()
    local navic = require('nvim-navic')
    if navic.is_available() then
        return navic.get_location()
    end
end
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
            highlight = true,
        })
    end,
    winbar = function()
        local columns = vim.api.nvim_get_option('columns')
        local sig = require('setup.lsp_signature').winbar()
        if sig == nil or sig.label == nil or sig.range == nil then
            return ' ' .. eval_navic()
        end
        local label1 = sig.label
        local label2 = ''
        if sig.range then
            label1 = sig.label:sub(1, sig.range['start'] - 1)
            label2 = sig.label:sub(sig.range['end'] + 1, #sig.label)
        end
        local doc = sig.doc or ''
        if #doc + #sig.label >= columns then
            local trim = math.max(5, columns - #sig.label - #sig.hint - 10)
            doc = doc:sub(1, trim) .. '...'
            -- lprint(doc)
        end

        return eval_navic()
            .. ' Signature: %#WinBarSignature#'
            .. label1
            .. '%*'
            .. '%#WinBarSigActParm#'
            .. sig.hint
            .. '%*'
            .. '%#WinBarSignature#'
            .. label2
    end,
}
