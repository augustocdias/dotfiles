return {
    setup = function()
        require('telescope').setup({
            defaults = {
                -- Appearance
                entry_prefix = ' ',
                prompt_prefix = ' ',
                selection_caret = ' ',
                color_devicons = true,

                -- Searching
                set_env = { COLORTERM = 'truecolor' },
                file_ignore_patterns = {
                    '.git/',
                    '%.jpg',
                    '%.jpeg',
                    '%.png',
                    '%.svg',
                    '%.otf',
                    '%.ttf',
                    '%.lock',
                    '__pycache__',
                    '%.sqlite3',
                    '%.ipynb',
                    'vendor',
                    'node_modules',
                    'dotbot',
                    'packer_compiled.lua',
                },

                -- Telescope smart history
                history = {
                    path = vim.fn.stdpath('data') .. '/databases/telescope_history.sqlite3',
                    limit = 100,
                },

                -- Mappings
                mappings = {
                    i = {
                        ['<ESC>'] = require('telescope.actions').close,
                        ['<C-j>'] = require('telescope.actions').move_selection_next,
                        ['<C-k>'] = require('telescope.actions').move_selection_previous,
                        ['<C-q>'] = require('telescope.actions').send_to_qflist,
                    },
                    n = { ['<ESC>'] = require('telescope.actions').close },
                },
            },
        })
        require('telescope').load_extension('fzf')
        require('telescope').load_extension('lsp_handlers')
        require('telescope').load_extension('dap')
        require('telescope').load_extension('session-lens')
        require('telescope').load_extension('file_browser')
    end,
}
