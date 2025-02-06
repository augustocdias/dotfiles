-- selene: allow(mixed_table)

return {
    setup = function()
        require('snacks').setup({
            bigfile = { enabled = true },
            bufdelete = { enabled = true },
            gitbrowse = { enabled = true },
            indent = { enabled = true, only_current = true },
            notifier = { enabled = true, style = 'fancy' },
            rename = { enabled = true },
            words = { enabled = true },
            styles = {
                blame_line = { border = 'none' },
                notification = { border = 'none' },
                notification_history = { border = 'none' },
                input = { relative = 'cursor' },
            },
            input = {
                enabled = true,
            },
            picker = {
                layout = {
                    preset = 'ivy',
                    layout = {
                        backdrop = 99,
                    },
                },
                ui_select = true, -- replace `vim.ui.select` with the snacks picker
                win = {
                    input = {
                        keys = {
                            ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
                        },
                    },
                },
                icons = {
                    ui = {
                        ignored = ' ',
                        hidden = ' ',
                        follow = '󰭔 ',
                    },
                    git = {
                        enabled = true, -- show git icons
                        commit = '󰜘 ', -- used by git log
                        staged = '● ', -- staged changes. always overrides the type icons
                        added = ' ',
                        deleted = ' ',
                        ignored = ' ',
                        modified = '○ ',
                        renamed = '󰑕 ',
                        unmerged = ' ',
                        untracked = ' ',
                    },
                    kinds = {
                        Control = ' ',
                        Collapsed = ' ',
                        Copilot = ' ',
                        Key = ' ',
                        Namespace = '󰦮 ',
                        Null = ' ',
                        Number = '󰎠 ',
                        Object = ' ',
                        Package = ' ',
                        String = ' ',
                        Unknown = ' ',

                        -- copy from cmp
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
            },
        })
    end,
}
