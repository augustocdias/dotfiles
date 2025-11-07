-- markdown enhancements -- alternative render-markdown
-- TODO: check markview lazy loading

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
    { 'markdown-plus', ft = { 'markdown',  'codecompanion' }, after = function() require('markdown-plus').setup()end },
    {
    'markview',
    event = 'DeferredUIEnter',
    priority = 59,
    ft = { 'markdown', 'codecompanion' },
    after = function() require('markview').setup({
        experimental = {
            prefer_nvim = true,
        },
        preview = {
            filetypes = { 'markdown', 'quarto', 'rmd', 'typst', 'Avante', 'codecompanion' },
            icon_provider = 'devicons',
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
    })end,
}}
