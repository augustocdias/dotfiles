return {
    setup = function()
        -- Set completeopt to have a better completion experience
        -- :help completeopt
        -- menuone: popup even when there's only one match
        -- noinsert: Do not insert text until a selection is made
        -- noselect: Do not select, force user to select one from the menu
        vim.o.completeopt = 'menu,menuone,noinsert,noselect'

        local lspkind = require('lspkind')
        local cmp = require('cmp')
        local Rule = require('nvim-autopairs.rule')
        local npairs = require('nvim-autopairs')

        local luasnip = require('luasnip')
        local luasnip_util = require('luasnip.util.util')
        local luasnip_types = require('luasnip.util.types')
        local custom_snippets_folder = vim.fn.stdpath('config') .. '/snippets'
        require('scissors').setup({
            snippetDir = custom_snippets_folder,
        })
        luasnip.config.setup({
            ext_ops = {
                [luasnip_types.choiceNode] = {
                    active = {
                        virt_text = { { '●', 'DevIconSml' } },
                    },
                },
                [luasnip_types.insertNode] = {
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
                        luasnip_util.normal_move_on(pos_begin)
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('v', true, false, true), 'n', true)
                        luasnip_util.normal_move_before(pos_end)
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

        -- local has_words_before = function()
        --     local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        --     return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
        -- end

        cmp.setup({
            experimental = {
                ghost_text = true,
            },
            completion = {
                completeopt = 'menu,menuone,noinsert',
            },
            view = {
                entries = { name = 'custom', selection_order = 'near_cursor' },
            },
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'nvim_lua' },
                { name = 'cmp_tabnine' },
                { name = 'path' },
                { name = 'copilot', group_index = 2 },
                { name = 'buffer' },
                { name = 'crates' },
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
            sorting = {
                comparators = {
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,

                    function(entry1, entry2)
                        local _, entry1_under = entry1.completion_item.label:find('^_+')
                        local _, entry2_under = entry2.completion_item.label:find('^_+')
                        entry1_under = entry1_under or 0
                        entry2_under = entry2_under or 0
                        if entry1_under > entry2_under then
                            return false
                        elseif entry1_under < entry2_under then
                            return true
                        end
                    end,
                    cmp.config.compare.kind,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
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
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                        -- elseif has_words_before() then
                        --     cmp.complete()
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
        require('luasnip.loaders.from_vscode').lazy_load({ paths = custom_snippets_folder })

        -- auto pairs setup
        npairs.setup()

        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

        npairs.add_rule(Rule('r#"', '"#', 'rust'))
        npairs.add_rule(Rule('|', '|', 'rust'))

        -- copilot
        vim.g.copilot_no_tab_map = true
        vim.g.copilot_assume_mapped = true

        require('copilot').setup({
            filetypes = {
                markdown = false,
            },
        })
        require('copilot_cmp').setup()

        -- create commands to manage snippets
        vim.api.nvim_create_user_command('SnippetAdd', function()
            require('scissors').addNewSnippet()
        end, {})
        vim.api.nvim_create_user_command('SnippetEdit', function()
            require('scissors').editSnippet()
        end, {})
    end,
}
