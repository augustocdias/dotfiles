local lualine = require('lualine')

local function search_result()
    if vim.v.hlsearch == 0 then
        return ''
    end
    local last_search = vim.fn.getreg('/')
    if not last_search or last_search == '' then
        return ''
    end
    local searchcount = vim.fn.searchcount({ maxcount = 9999 })
    return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
end

lualine.setup({
    options = {
        icons_enabled = true,
        theme = 'auto',
        section_separators = { right = ' ', left = ' ' },
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
            search_result,
            'encoding',
            'filetype',
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                always_visible = true,
            },
        },
        lualine_y = {
            'location',
            'progress',
        },
        lualine_z = {
            require('weather.lualine').default_c({}),
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
