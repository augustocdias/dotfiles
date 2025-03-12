-- status line

return {
    'nvim-lualine/lualine.nvim',
    event = 'UIEnter',
    config = function()
        local command_status = require('utils').command_status(require('utils').noice_status_color(vim.g.flavour))

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
        require('lualine').setup({
            options = {
                icons_enabled = true,
                theme = 'auto',
                section_separators = { left = '', right = '' },
                -- section_separators = { left = ' ', right = ' ' },
                -- section_separators = { left = '', right = '' },
                -- section_separators = { left = '', right = '' },
                component_separators = { left = '', right = '' },
                -- component_separators = { left = '', right = '' },
                -- component_separators = { left = '', right = '' },
                -- component_separators = { left = '', right = '' },
                disabled_filetypes = {
                    winbar = { 'neo-tree', 'packer', 'help', 'terminal' },
                },
                globalstatus = true,
            },
            sections = {
                lualine_a = { { 'mode' } },
                lualine_b = { 'diff', 'branch' },
                lualine_c = {
                    {
                        'filename',
                        file_status = true, -- displays file status (readonly status, modified status)
                        path = 1,           -- 0 = just filename, 1 = relative path, 2 = absolute path
                    },
                },
                lualine_x = {
                    command_status,
                    search_result,
                    'encoding',
                    'filetype',
                },
                lualine_y = {
                    {
                        'diagnostics',
                        sources = { 'nvim_diagnostic' },
                        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                        always_visible = true,
                    },
                },
                lualine_z = {
                    'location',
                    'progress',
                    function()
                        if vim.fn.reg_recording() ~= '' then
                            return 'Recording @' .. vim.fn.reg_recording()
                        else
                            return ''
                        end
                    end,
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        'filename',
                        file_status = true, -- displays file status (readonly status, modified status)
                        path = 1,           -- 0 = just filename, 1 = relative path, 2 = absolute path
                    },
                },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {},
        })
    end,
}
