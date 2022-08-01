local lspkind = require('lspkind')
local luasnip = require('luasnip')
local cmp = require('cmp')
local Rule = require('nvim-autopairs.rule')
local npairs = require('nvim-autopairs')

local types = require('luasnip.util.types')
luasnip.config.setup({
    ext_ops = {
        [types.choiceNode] = {
            active = {
                virt_text = { { '●', 'DevIconSml' } },
            },
        },
        [types.insertNode] = {
            active = {
                virt_text = { { '●', 'DevIconC' } },
            },
        },
    },
    parser_nested_assembler = function(_, snippet)
        local select = function(snip, no_move)
            snip.parent:enter_node(snip.indx)
            -- upon deletion, extmarks of inner nodes should shift to end of
            -- placeholder-text.
            for _, node in ipairs(snip.nodes) do
                node:set_mark_rgrav(true, true)
            end

            -- SELECT all text inside the snippet.
            if not no_move then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
                local pos_begin, pos_end = snip.mark:pos_begin_end()
                util.normal_move_on(pos_begin)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('v', true, false, true), 'n', true)
                util.normal_move_before(pos_end)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('o<C-G>', true, false, true), 'n', true)
            end
        end
        function snippet:jump_into(dir, no_move)
            if self.active then
                -- inside snippet, but not selected.
                if dir == 1 then
                    self:input_leave()
                    return self.next:jump_into(dir, no_move)
                else
                    select(self, no_move)
                    return self
                end
            else
                -- jumping in from outside snippet.
                self:input_enter()
                if dir == 1 then
                    select(self, no_move)
                    return self
                else
                    return self.inner_last:jump_into(dir, no_move)
                end
            end
        end

        -- this is called only if the snippet is currently selected.
        function snippet:jump_from(dir, no_move)
            if dir == 1 then
                return self.inner_first:jump_into(dir, no_move)
            else
                self:input_leave()
                return self.prev:jump_into(dir, no_move)
            end
        end

        return snippet
    end,
})

-- set keymap for navigating through snippet choices
vim.keymap.set({ 'i', 's' }, '<a-l>', function()
    if luasnip.choice_active() then
        luasnip.change_choice(1)
    end
end)
vim.keymap.set({ 'i', 's' }, '<a-h>', function()
    if luasnip.choice_active() then
        luasnip.change_choice(-1)
    end
end)

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
    copilot = '[Copilot]',
}

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup({
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },
    view = {
        entries = { name = 'custom', selection_order = 'near_cursor' },
    },
    sources = {
        { name = 'nvim_lsp', priority = 99 },
        { name = 'luasnip', priority = 90 },
        { name = 'nvim_lua', priority = 80 },
        { name = 'cmp_tabnine', priority = 80 },
        { name = 'path', priority = 10 },
        { name = 'copilot', group_index = 2 },
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
            elseif entry.source.name == 'copilot' then
                vim_item.kind = 'ﯙ Copilot'
                vim_item.kind_hl_group = 'CmpItemKindCopilot'
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
    mapping = require('cmp').mapping.preset.cmdline(),
})

require('cmp').setup.cmdline(':', {
    sources = {
        { name = 'cmdline' },
        { name = 'path' },
    },
    mapping = require('cmp').mapping.preset.cmdline(),
})

require('luasnip.loaders.from_vscode').load()

require('nvim-treesitter.configs').setup({
    ensure_installed = 'all',
    ignore_install = {
        'phpdoc',
    },
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

-- require('vim.treesitter.query').set_query(
--     'rust',
--     'injections',
--     [[
-- ((
--   (raw_string_literal) @constant
--   (#match? @constant "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).*")
-- ) @injection.content (#set! injection.language "sql"))
-- ]]
-- ) -- inject sql in raw_string_literals
require('vim.treesitter.query').set_query(
    'rust',
    'injections',
    [[
((
  (line_comment) @constant
) @injection.content (#set! injection.language "markdown_inline"))
]]
) -- inject markdown in comments

-- auto pairs setup
npairs.setup()

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))

npairs.add_rule(Rule('r#"', '"#', 'rust'))
npairs.add_rule(Rule('|', '|', 'rust'))

-- copilot
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

require('copilot').setup({
    ft_disable = { 'markdown' },
})
