-- markdown enhancements -- alternative render-markdown

local function conceal_tag(icon, hl_group)
    return {
        on_node = { hl_group = hl_group },
        on_closing_tag = { conceal = '' },
        on_opening_tag = {
            conceal = '',
            virt_text_pos = 'inline',
            virt_text = { { icon .. ' ', hl_group } },
        },
    }
end

return {
    'OXY2DEV/markview.nvim',
    event = 'VeryLazy',
    priority = 49,
    ft = { 'markdown', 'Avante', 'codecompanion' },
    dependencies = {
        { 'yousefhadder/markdown-plus.nvim', ft = { 'markdown', 'Avante', 'codecompanion' }, config = true },
    },
    opts = {
        experimental = {
            prefer_nvim = true,
        },
        preview = {
            filetypes = { 'markdown', 'quarto', 'rmd', 'typst', 'Avante', 'codecompanion' },
            icon_provider = 'mini',
            ignore_buftypes = {},
        },
        html = {
            container_elements = {
                ['^buf$'] = conceal_tag('', 'CodeCompanionChatVariable'),
                ['^file$'] = conceal_tag('', 'CodeCompanionChatVariable'),
                ['^help$'] = conceal_tag('󰘥', 'CodeCompanionChatVariable'),
                ['^image$'] = conceal_tag('', 'CodeCompanionChatVariable'),
                ['^symbols$'] = conceal_tag('', 'CodeCompanionChatVariable'),
                ['^url$'] = conceal_tag('󰖟', 'CodeCompanionChatVariable'),
                ['^var$'] = conceal_tag('', 'CodeCompanionChatVariable'),
                ['^tool$'] = conceal_tag('', 'CodeCompanionChatTool'),
                ['^user_prompt$'] = conceal_tag('', 'CodeCompanionChatTool'),
                ['^group$'] = conceal_tag('', 'CodeCompanionChatToolGroup'),
            },
        },
    },
}
