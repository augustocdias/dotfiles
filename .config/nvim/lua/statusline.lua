local lualine = require('lualine')

lualine.setup({
    options = {
        icons_enabled = true,
        theme = 'tokyonight',
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = {},
        globalstatus = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'diff', 'branch' },
        lualine_c = {
            {
                'filename',
                file_status = true, -- displays file status (readonly status, modified status)
                path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
            },
            {
                function()
                    local sig = require('lsp_signature').status_line()
                    return sig.hint
                end,
            },
        },
        lualine_x = {
            require('weather.lualine').default_c({}),
            'encoding',
            'filetype',
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                diagnostics_color = {
                    error = 'DiagnosticError',
                    warn = 'DiagnosticWarn',
                    info = 'DiagnosticInfo',
                    hint = 'DiagnosticHint',
                },
                always_visible = true,
            },
        },
        lualine_y = {
            'progress',
        },
        lualine_z = {
            'location',
        },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            {
                'filename',
                file_status = true, -- displays file status (readonly status, modified status)
                path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
            },
        },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    extensions = { 'quickfix', 'nvim-tree', 'fzf' },
})
