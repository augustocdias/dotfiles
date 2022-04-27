local lspkind = require('lspkind')
local luasnip = require('luasnip')
local cmp = require('cmp')
local Rule = require('nvim-autopairs.rule')
local npairs = require('nvim-autopairs')

-- copilot settings
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

local lspkind_opts = {
    with_text = true,
    preset = 'codicons', -- need to install font https://github.com/microsoft/vscode-codicons/blob/main/dist/codicon.ttf
}

local source_mapping = {
    nvim_lsp = '[LSP]',
    luasnip = '[Snippet]',
    treesitter = '[TS]',
    cmp_tabnine = '[TN]',
    nvim_lua = '[Vim]',
    path = '[Path]',
    buffer = '[Buffer]',
    crates = '[Crates]',
}

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup({
    sources = {
        { name = 'nvim_lsp', priority = 99 },
        { name = 'luasnip', priority = 90 },
        { name = 'nvim_lua', priority = 80 },
        { name = 'cmp_tabnine', priority = 80 },
        { name = 'path', priority = 10 },
        { name = 'buffer', priority = 0 },
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = lspkind.symbolic(vim_item.kind, lspkind_opts)
            local menu = source_mapping[entry.source.name]
            if entry.source.name == 'cmp_tabnine' then
                if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
                    menu = entry.completion_item.data.detail .. ' ' .. menu
                end
                vim_item.kind = ' TabNine'
            end
            vim_item.menu = menu
            return vim_item
        end,
    },
    mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-f>'] = cmp.mapping.scroll_docs(-4),
        ['<C-b>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Esc>'] = cmp.mapping.close(),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
    },
})

require('cmp').setup.cmdline('/', {
    sources = {
        { name = 'nvim_lsp_document_symbol' },
        { name = 'buffer' },
    },
})

require('cmp').setup.cmdline(':', {
    sources = {
        { name = 'cmdline' },
        { name = 'path' },
    },
})

require('luasnip.loaders.from_vscode').load()

require('nvim-treesitter.configs').setup({
    ensure_installed = 'all',
    highlight = {
        enable = true,
        -- add languages not supported by treesitter here
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
        disable = {
            'rust',
            'python',
        },
    },
    matchup = {
        enable = true,
    },
    textobjects = {
        select = {
            keymaps = {
                ['uc'] = '@comment.outer',
            },
        },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
        },
    },
})

require('vim.treesitter.query').set_query(
    'rust',
    'injections',
    [[
((
  (raw_string_literal) @constant
  (#match? @constant "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).*")
) @injection.content (#set! injection.language "sql"))
]]
) -- inject sql in raw_string_literals

-- auto pairs setup
npairs.setup()

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))

npairs.add_rule(Rule('r#"', '"#', 'rust'))
npairs.add_rule(Rule('|', '|', 'rust'))
