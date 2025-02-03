return {
    setup = function()
        require('colorful-menu').setup()
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

        local disabled_filetypes = { 'minifiles', 'DressingInput' }

        require('blink.cmp').setup({
            -- Disable for some filetypes
            enabled = function()
                return vim.bo.buftype ~= 'prompt'
                    and vim.b.completion ~= false
                    and not vim.tbl_contains(disabled_filetypes, vim.bo.filetype)
            end,
            signature = { enabled = true },
            snippets = {
                preset = 'luasnip',
                expand = function(snippet)
                    require('luasnip').lsp_expand(snippet)
                end,
                active = function(filter)
                    if filter and filter.direction then
                        return require('luasnip').jumpable(filter.direction)
                    end
                    return require('luasnip').in_snippet()
                end,
                jump = function(direction)
                    require('luasnip').jump(direction)
                end,
            },
            sources = {
                default = function()
                    local success, node = pcall(vim.treesitter.get_node)
                    local is_comment = success
                        and node
                        and vim.tbl_contains(
                            { 'comment', 'line_comment', 'block_comment', 'doc', 'doc_comment' },
                            node:type()
                        )
                    if is_comment then
                        return { 'lsp', 'buffer' }
                    else
                        return { 'lsp', 'snippets', 'path' }
                    end
                end,
            },
            completion = {
                ghost_text = { enabled = true },
                list = {
                    selection = {
                        preselect = function(ctx)
                            return ctx.mode ~= 'cmdline'
                        end,
                        auto_insert = false,
                    },
                },
                documentation = {
                    auto_show = true,
                },
                menu = {
                    auto_show = function(ctx)
                        return ctx.mode ~= 'cmdline' or not vim.tbl_contains({ '/', '?' }, vim.fn.getcmdtype())
                    end,
                    draw = {
                        treesitter = { 'lsp' },
                        columns = {
                            { 'kind_icon', gap = 1 },
                            { 'label', gap = 3 },
                            { 'item_idx', gap = 1 },
                            { 'source_name' },
                        },
                        components = {
                            label = {
                                text = function(ctx)
                                    return require('colorful-menu').blink_components_text(ctx)
                                end,
                                highlight = function(ctx)
                                    return require('colorful-menu').blink_components_highlight(ctx)
                                end,
                            },
                            item_idx = {
                                text = function(ctx)
                                    return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx)
                                end,
                                highlight = 'BlinkCmpItemIdx',
                            },
                            source_name = {
                                text = function(ctx)
                                    return '[' .. ctx.source_name .. ']'
                                end,
                            },
                        },
                    },
                },
            },
            fuzzy = {
                sorts = { 'score', 'sort_text', 'kind', 'label' },
            },
            keymap = {
                preset = 'none',
                cmdline = { -- https://github.com/neovim/neovim/issues/21585
                    ['<C-space>'] = { 'show' },
                    ['<CR>'] = { 'accept', 'fallback' },
                    ['<Tab>'] = { 'select_next', 'fallback' },
                    ['<S-Tab>'] = { 'select_prev', 'fallback' },
                    ['<Esc>'] = {
                        'cancel',
                        function()
                            if vim.fn.getcmdtype() ~= '' then
                                vim.api.nvim_feedkeys(
                                    vim.api.nvim_replace_termcodes('<C-c>', true, true, true),
                                    'n',
                                    true
                                )
                                return
                            end
                        end,
                    },
                },
                ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                ['<Esc>'] = { 'cancel', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },

                ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

                ['<M-Tab>'] = { 'snippet_forward', 'fallback' },
                ['<M-S-Tab>'] = { 'snippet_backward', 'fallback' },
                ['<Tab>'] = { 'select_next', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'fallback' },
                ['<A-1>'] = {
                    function(cmp)
                        cmp.accept({ index = 1 })
                    end,
                },
                ['<A-2>'] = {
                    function(cmp)
                        cmp.accept({ index = 2 })
                    end,
                },
                ['<A-3>'] = {
                    function(cmp)
                        cmp.accept({ index = 3 })
                    end,
                },
                ['<A-4>'] = {
                    function(cmp)
                        cmp.accept({ index = 4 })
                    end,
                },
                ['<A-5>'] = {
                    function(cmp)
                        cmp.accept({ index = 5 })
                    end,
                },
                ['<A-6>'] = {
                    function(cmp)
                        cmp.accept({ index = 6 })
                    end,
                },
                ['<A-7>'] = {
                    function(cmp)
                        cmp.accept({ index = 7 })
                    end,
                },
                ['<A-8>'] = {
                    function(cmp)
                        cmp.accept({ index = 8 })
                    end,
                },
                ['<A-9>'] = {
                    function(cmp)
                        cmp.accept({ index = 9 })
                    end,
                },
                ['<A-0>'] = {
                    function(cmp)
                        cmp.accept({ index = 10 })
                    end,
                },
            },
            appearance = {
                highlight_ns = vim.api.nvim_create_namespace('blink_cmp'),
                -- Sets the fallback highlight groups to nvim-cmp's highlight groups
                -- Useful for when your theme doesn't support blink.cmp
                -- Will be removed in a future release
                use_nvim_cmp_as_default = false,
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'normal',
                kind_icons = {
                    Text = '',
                    Method = '󰊕',
                    Function = '󰊕',
                    Constructor = '',
                    Field = '󰜢',
                    Variable = '',
                    Class = '',
                    Interface = '',
                    Module = '',
                    Property = '',
                    Unit = '',
                    Value = '',
                    Enum = '',
                    Keyword = '󱕴',
                    Snippet = '',
                    Color = '',
                    File = '',
                    Reference = '',
                    Folder = '',
                    EnumMember = '',
                    Constant = '󰏿',
                    Struct = '',
                    Event = '',
                    Operator = '',
                    TypeParameter = '',
                    Boolean = ' ',
                    Array = ' ',
                },
            },
        })

        require('luasnip.loaders.from_vscode').load()
        require('luasnip.loaders.from_vscode').lazy_load({ paths = custom_snippets_folder })

        -- create commands to manage snippets
        vim.api.nvim_create_user_command('SnippetAdd', function()
            require('scissors').addNewSnippet()
        end, {})
        vim.api.nvim_create_user_command('SnippetEdit', function()
            require('scissors').editSnippet()
        end, {})
    end,
}
