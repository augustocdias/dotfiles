local no_remap_opt = { noremap = true }
local silent_opt = { silent = true }
local no_remap_silent_opt = { noremap = true, silent = true }
local no_remap_silent_expr_opt = { noremap = true, silent = true, expr = true }

local sidebar = require('sidebar')

local keymap_table = {
    {
        shortcut = '<M-n>',
        cmd = function()
            require('setup.neorg').open_workspace_notes()
        end,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Open Notes for Current Project',
        enabled = true,
    },
    {
        shortcut = 's',
        cmd = function()
            require('flash').jump()
        end,
        opts = no_remap_opt,
        modes = { 'n', 'x', 'o' },
        description = 'Flash',
        enabled = true,
    },
    {
        shortcut = 'S',
        cmd = function()
            require('flash').treesitter()
        end,
        opts = no_remap_opt,
        modes = { 'n', 'x', 'o' },
        description = 'Flash Treesitter',
        enabled = true,
    },
    {
        shortcut = 'r',
        cmd = function()
            require('flash').remote()
        end,
        opts = no_remap_opt,
        modes = { 'o' },
        description = 'Flash Remote',
        enabled = true,
    },
    {
        shortcut = 'R',
        cmd = function()
            require('flash').treesitter_search()
        end,
        opts = no_remap_opt,
        modes = { 'x', 'o' },
        description = 'Flash Treesitter Search',
        enabled = true,
    },
    {
        shortcut = ']c',
        cmd = function()
            if vim.wo.diff then
                return ']c'
            end
            vim.schedule(function()
                require('gitsigns').next_hunk()
            end)
            return '<Ignore>'
        end,
        opts = { expr = true },
        modes = { 'n' },
        description = 'Next git hunk',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '[c',
        cmd = function()
            if vim.wo.diff then
                return '[c'
            end
            vim.schedule(function()
                require('gitsigns').prev_hunk()
            end)
            return '<Ignore>'
        end,
        opts = { expr = true },
        modes = { 'n' },
        description = 'Previous git hunk',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '+',
        cmd = '<C-a>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Increment number',
        enabled = true,
    },
    {
        shortcut = '-',
        cmd = '<C-x>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Decrement number',
        enabled = true,
    },
    {
        shortcut = '<C-a>',
        cmd = 'gg<S-v>G',
        opts = {},
        modes = { 'n' },
        description = 'Select all',
        enabled = true,
    },
    {
        shortcut = '<M-p>',
        cmd = function()
            require('telescope.builtin').buffers()
        end,
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Open buffers',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-p>',
        cmd = function()
            require('telescope.builtin').find_files()
        end,
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Open file in workspace',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<M-r>',
        cmd = ':e!<CR>',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Refresh buffer',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<M-w>',
        cmd = function()
            require('auto-session.session-lens').search_session()
        end,
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Open saved session',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<M-t>',
        cmd = ':Trouble diagnostics toggle focus=true<CR>',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Show diagnostics pane',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = 'n',
        cmd = 'nzz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
        enabled = true,
    },
    {
        shortcut = 'p',
        cmd = '<Cmd>silent! normal! "_dP<CR>',
        opts = no_remap_opt,
        modes = { 'x' },
        description = "Smarter Paste in Visual (won't yank deleted content)",
        enabled = true,
    },
    {
        shortcut = 'dd',
        cmd = function()
            if vim.api.nvim_get_current_line():match('^%s*$') then
                return '"_dd'
            else
                return 'dd'
            end
        end,
        opts = no_remap_silent_expr_opt,
        modes = { 'n' },
        description = "Smarter DD (empty lines won't be yanked)",
        enabled = true,
    },
    {
        shortcut = 'N',
        cmd = 'Nzz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
        enabled = true,
    },
    {
        shortcut = '*',
        cmd = '*zz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
        enabled = true,
    },
    {
        shortcut = '#',
        cmd = '#zz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
        enabled = true,
    },
    {
        shortcut = 'g*',
        cmd = 'g*zz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
        enabled = true,
    },
    {
        shortcut = '?',
        cmd = '?\\v',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Improve search',
        enabled = true,
    },
    {
        shortcut = '/',
        cmd = '/\\v',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Improve search',
        enabled = true,
    },
    {
        shortcut = '\\',
        cmd = '/@',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Improve search',
        enabled = true,
    },
    {
        shortcut = '%s/',
        cmd = '%sm/',
        opts = no_remap_opt,
        modes = { 'c' },
        description = 'Improve search',
        enabled = true,
    },
    {
        shortcut = '<F2>',
        cmd = ':lua MiniFiles.open()<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Toggle File Manager',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-x>',
        cmd = ':lua MiniBufremove.delete()<CR>',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Close current buffer',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<M><left>',
        cmd = function()
            require('setup.apple').music:previous_track()
        end,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Previous Song (Apple Music)',
        enabled = true,
    },
    {
        shortcut = '<M><right>',
        cmd = function()
            require('setup.apple').music:next_track()
        end,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Next Song (Apple Music)',
        enabled = true,
    },
    {
        shortcut = '<M-/>',
        cmd = function()
            require('setup.apple').music:play_pause()
        end,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Play/Pause (Apple Music)',
        enabled = true,
    },
    {
        shortcut = '<C-g>',
        cmd = ':nohlsearch<CR>',
        opts = no_remap_silent_opt,
        modes = { 'n', 'v' },
        description = 'Clear search',
        enabled = true,
    },
    {
        shortcut = 'H',
        cmd = '^',
        opts = {},
        modes = { 'n', 'v' },
        description = 'Jump to start of the line',
        enabled = true,
    },
    {
        shortcut = 'L',
        cmd = '$',
        opts = {},
        modes = { 'n', 'v' },
        description = 'Jump to end of the line',
        enabled = true,
    },
    {
        shortcut = '<C-h>',
        cmd = '<Left>',
        opts = no_remap_opt,
        modes = { 'i', 'c' },
        description = 'Move cursor left',
        enabled = true,
    },
    {
        shortcut = '<C-j>',
        cmd = '<Down>',
        opts = no_remap_opt,
        modes = { 'i', 'c' },
        description = 'Move cursor down',
        enabled = true,
    },
    {
        shortcut = '<C-k>',
        cmd = '<Up>',
        opts = no_remap_opt,
        modes = { 'i', 'c' },
        description = 'Move cursor up',
        enabled = true,
    },
    {
        shortcut = '<C-l>',
        cmd = '<Right>',
        opts = no_remap_opt,
        modes = { 'i', 'c' },
        description = 'Move cursor right',
        enabled = true,
    },
    {
        shortcut = '<C-h>',
        cmd = '<C-w><left>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Focus on window to the left',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-l>',
        cmd = '<C-w><right>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Focus on window to the right',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-k>',
        cmd = '<C-w><up>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Focus on window up',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-j>',
        cmd = '<C-w><down>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Focus on window down',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<right>',
        cmd = '<CMD>vertical resize +2<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Increase window width',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<left>',
        cmd = '<CMD>vertical resize -2<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Decrease window width',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<up>',
        cmd = '<CMD>resize +2<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Increase window height',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<down>',
        cmd = '<CMD>resize -2<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Decrease window height',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-d>',
        cmd = '<C-o>x',
        opts = no_remap_opt,
        modes = { 'i' },
        description = 'Delete char forward in insert mode',
        enabled = true,
    },
    {
        shortcut = '<F1>',
        cmd = ':Trouble todo toggle<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Toggle todo list',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-s>',
        cmd = ':wa<CR>',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Savel all',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-s>',
        cmd = '<C-o>:wa<CR>',
        opts = no_remap_silent_opt,
        modes = { 'i' },
        description = 'Savel all',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '[g',
        cmd = vim.diagnostic.goto_prev,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Go to previous diagnostic',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = ']g',
        cmd = vim.diagnostic.goto_next,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Go to next diagnostic',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = 'gx',
        cmd = '<CMD>Browse<CR>',
        opts = silent_opt,
        modes = { 'n', 'x' },
        description = 'Open links in browser',
        enabled = true,
    },
    {
        shortcut = 'gD',
        cmd = vim.lsp.buf.declaration,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Go to declaration',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = 'gt',
        cmd = vim.lsp.buf.type_definition,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Go to type definition',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = 'gd',
        cmd = vim.lsp.buf.definition,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Go to definition',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = 'gi',
        cmd = vim.lsp.buf.implementation,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Go to implementation',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = 'gr',
        cmd = function()
            vim.lsp.buf.references({ includeDeclaration = false })
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Find references',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<M-s>',
        cmd = vim.lsp.buf.signature_help,
        opts = silent_opt,
        modes = { 'i' },
        description = 'Signature help',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<M-s>',
        cmd = vim.lsp.buf.signature_help,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Signature help',
        enabled = not vim.g.vscode,
    },
    -- call twice make the cursor go into the float window. good for navigating big docs
    {
        shortcut = 'K',
        cmd = vim.lsp.buf.hover,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Show hover popup',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<M-f>',
        cmd = function()
            vim.lsp.buf.format({ async = false })
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Format code',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<F4>',
        cmd = function()
            require('dap').repl.toggle()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Toggle repl',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<F5>',
        cmd = function()
            require('dap').continue()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Continue',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<S-F5>',
        cmd = function()
            require('dap').close()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Stop',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-F5>',
        cmd = function()
            require('dap').run_last()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Run last',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<F6>',
        cmd = function()
            require('dap').pause()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Pause',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<F9>',
        cmd = function()
            require('dap').toggle_breakpoint()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Toggle breakpoint',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<S-F9>',
        cmd = function()
            require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Set breakpoint with condition',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<C-F9>',
        cmd = function()
            require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Set logpoint',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<F10>',
        cmd = function()
            require('dap').step_over()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Step over',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<S-F10>',
        cmd = function()
            require('dap').run_to_cursor()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Run to cursor',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<F11>',
        cmd = function()
            require('dap').step_into()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Step into',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<S-F11>',
        cmd = function()
            require('dap').step_out()
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Step out',
        enabled = not vim.g.vscode,
    },
    {
        shortcut = '<F7>',
        cmd = function()
            require('dap.ui.widgets').hover()
        end,
        opts = silent_opt,
        modes = { 'x' },
        description = 'DAP Hover',
        enabled = not vim.g.vscode,
    },
}

return {
    keymap_table = keymap_table,
    which_key = {
        visual = {
            maps = {
                j = {
                    name = 'Java',
                    a = { '<cmd>lua require("jdtls").code_action(true)', 'Code Action' },
                    e = { '<cmd>lua require("jdtls").extract_variable(true)', 'Extract Variable' },
                    c = { '<cmd>lua require("jdtls").extract_constant(true)', 'Extract Constant' },
                    m = { '<cmd>lua require("jdtls").extract_method(true)', 'Extract Method' },
                },
                ['c'] = { '"*y', 'Copy selection to system clipboard' },
                l = {
                    name = 'LSP',
                    a = { '<cmd>lua vim.lsp.buf.range_code_action()<CR>', 'Range Code Action' },
                },
                h = {
                    name = 'Gitsigns',
                    s = {
                        function()
                            require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                        end,
                        'Stage Hunk',
                    },
                    r = {
                        function()
                            require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                        end,
                        'Reset Hunk',
                    },
                },
                n = {
                    name = 'Refactoring',
                    e = { ':Refactor extract', 'Extract' },
                    f = { ':Refactor extract_to_file ', 'Extract to file' },
                    i = { ':Refactor inline_var', 'Inline Variable' },
                    v = { ':Refactor extract_var ', 'Extract Variable' },
                    r = { '<cmd>lua require("telescope").extensions.refactoring.refactors()<CR>', 'Refactors' },
                    p = { '<cmd>lua require("refactoring").debug.print_var()<CR>', 'Print Variable' },
                },
            },
            opts = {
                prefix = '<leader>',
                noremap = true,
                silent = true,
                mode = 'v',
            },
        },
        normal = {
            maps = {
                f = {
                    name = 'File',
                    b = { '<cmd>lua require("telescope.builtin").buffers()<CR>', 'Buffers' },
                    f = { '<cmd>lua require("telescope.builtin").find_files()<CR>', 'Files' },
                    w = { '<cmd>lua require("telescope").extensions.file_browser.file_browser()<CR>', 'File Browser' },
                    o = { '<cmd>lua require("telescope.builtin").oldfiles()<CR>', 'Prev Open Files' },
                },
                v = {
                    name = 'Vim',
                    q = { '<cmd>lua require("telescope.builtin").quickfix()<CR>', 'Quickfix List' },
                    l = { '<cmd>lua require("telescope.builtin").loclist()<CR>', 'Location List' },
                    j = { '<cmd>lua require("telescope.builtin").jumplist()<CR>', 'Jump List' },
                    c = { '<cmd>lua require("telescope.builtin").commands()<CR>', 'Commands' },
                    h = { '<cmd>lua require("telescope.builtin").command_history()<CR>', 'Command History' },
                    s = { '<cmd>lua require("telescope.builtin").search_history()<CR>', 'Search History' },
                    m = { '<cmd>lua require("telescope.builtin").man_pages()<CR>', 'Man Pages' },
                    k = { '<cmd>lua require("telescope.builtin").marks()<CR>', 'Marks' },
                    o = { '<cmd>lua require("telescope.builtin").colorscheme()<CR>', 'Colorscheme' },
                    r = { '<cmd>lua require("telescope.builtin").registers()<CR>', 'Registers' },
                    a = { '<cmd>lua require("telescope.builtin").autocommands()<CR>', 'Autocommands' },
                    p = { '<cmd>lua require("telescope.builtin").vim_options()<CR>', 'Vim Options' },
                    e = { '<cmd>lua require("telescope.builtin").spell_suggest()<CR>', 'Spell Suggestions' },
                    y = { '<cmd>lua require("telescope.builtin").keymaps()<CR>', 'Normal Mode Keymaps' },
                },
                p = {
                    name = 'Grep',
                    g = { '<cmd>lua require("telescope.builtin").grep_string()<CR>', 'Grep String' },
                    l = { '<cmd>lua require("telescope.builtin").live_grep()<CR>', 'Live Grep' },
                    r = {
                        '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>',
                        'Live Grep Raw',
                    },
                    s = { ':Spectre<CR>', 'Spectre' },
                    w = {
                        '<cmd>lua require("spectre").open_visual({select_word = true})<CR>',
                        'Spectre Current Word',
                    },
                },
                g = {
                    name = 'Git',
                    f = { '<cmd>lua require("telescope.builtin").git_files()<CR>', 'Files' },
                    s = { '<cmd>lua require("telescope.builtin").git_status()<CR>', 'Status' },
                    c = { '<cmd>lua require("telescope.builtin").git_commits()<CR>', 'Commit Log' },
                    l = { '<cmd>lua require("telescope.builtin").git_bcommits()<CR>', 'Commit Log Current Buffer' },
                    b = { '<cmd>lua require("telescope.builtin").git_branches()<CR>', 'Branches' },
                    t = { '<cmd>lua require("telescope.builtin").git_stash()<CR>', 'Stash' },
                    d = { ':DiffviewOpen<CR>', 'Open Diff View' },
                    x = { ':DiffviewClose<CR>', 'Close Diff View' },
                    r = { ':DiffviewRefresh<CR>', 'Diff View Refresh' },
                    e = { ':DiffviewFocusFiles<CR>', 'Diff View Focus Files' },
                    h = { ':DiffviewFileHistory<CR>', 'Diff View File History' },
                },
                h = {
                    name = 'Gitsigns',
                    s = { ':Gitsigns stage_hunk<CR>', 'Stage hunk' },
                    S = { ':Gitsigns stage_buffer<CR>', 'Stage buffer' },
                    u = { ':Gitsigns undo_stage_hunk<CR>', 'Undo stage hunk' },
                    r = { ':Gitsigns reset_hunk<CR>', 'Reset hunk' },
                    R = { ':Gitsigns reset_buffer<CR>', 'Reset buffer' },
                    p = { ':Gitsigns preview_hunk<CR>', 'Preview hunk' },
                    b = { ':Gitsigns toggle_current_line_blame<CR>', 'Toggle blame current line' },
                    B = {
                        '<cmd>lua require("gitsigns").blame_line({full=true, ignore_whitespace = true})<CR>',
                        'Blame line',
                    },
                    d = { ':Gitsigns diffthis<CR>', 'Diff this' },
                    t = { ':Gitsigns toggle_deleted<CR>', 'Toggle deleted hunks' },
                },
                l = {
                    name = 'LSP',
                    a = { '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Actions' },
                    b = { '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', 'Show line diagnostics' },
                    c = {
                        function()
                            vim.b.autoformat = not vim.b.autoformat
                        end,
                        'Toggle autoformat',
                    },
                    d = { '<cmd>lua require("telescope.builtin").lsp_definitions()<CR>', 'Definitions' },
                    e = { '<cmd>lua require("telescope.builtin").treesitter()<CR>', 'Treesitter' },
                    f = { '<cmd>lua vim.lsp.buf.format({ async = false })<CR>', 'Format' },
                    g = {
                        '<cmd>lua require("telescope.builtin").lsp_document_diagnostics()<CR>',
                        'Document Diagnostics',
                    },
                    i = { '<cmd>lua require("telescope.builtin").lsp_implementations()<CR>', 'Implementations' },
                    l = { '<cmd>lua vim.lsp.codelens.run()<CR>', 'Code Lens' },
                    m = { '<cmd>lua vim.lsp.buf.rename()<CR>', 'Rename symbol' },
                    o = {
                        '<cmd>lua require("telescope.builtin").diagnostics()<CR>',
                        'Workspace Diagnostics',
                    },
                    q = { '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', 'Diagnostic set loclist' },
                    r = { '<cmd>lua require("telescope.builtin").lsp_references()<CR>', 'References' },
                    s = { '<cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>', 'Document Symbols' },
                    t = { '<cmd>lua require("telescope.builtin").lsp_type_definitions()<CR>', 'Type Definitions' },
                    v = {
                        '<cmd>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>',
                        'Dynamic Workspace Symbols',
                    },
                    w = {
                        '<cmd>lua require("telescope.builtin").lsp_workspace_symbols()<CR>',
                        'Workspace Symbols',
                    },
                },
                t = {
                    name = 'Telescope',
                    s = { '<cmd>lua require("telescope.builtin").planets()<CR>', 'Use Telescope...' },
                    c = { '<cmd>lua require("telescope.builtin").builtin()<CR>', 'Builtin Pickers' },
                    h = { '<cmd>lua require("telescope.builtin").reloader()<CR>', 'Reload Lua Modules' },
                    y = {
                        '<cmd>lua require("telescope.builtin").symbols({"emoji", "kaomoji", "gitmoji", "julia", "math", "nerd"})<CR>',
                        'List Symbols',
                    },
                    m = { '<cmd>lua require("telescope.builtin").resume()<CR>', 'Resume Last Picker' },
                    r = { '<cmd>lua require("telescope.builtin").pickers()<CR>', 'Previous Pickers' },
                },
                d = {
                    name = 'Debug',
                    c = { '<cmd>lua require("telescope").extensions.dap.commands()<CR>', 'Commands' },
                    f = { '<cmd>lua require("telescope").extensions.dap.configurations()<CR>', 'Configurations' },
                    b = { '<cmd>lua require("telescope").extensions.dap.list_breakpoints()<CR>', 'Breakpoints' },
                    v = { '<cmd>lua require("telescope").extensions.dap.variables()<CR>', 'Variables' },
                    r = { '<cmd>lua require("telescope").extensions.dap.frames()<CR>', 'Frames' },
                },
                r = {
                    name = 'Rust',
                    r = { ':RustLsp runnables<CR>', 'Runnables' },
                    d = { ':RustLsp debuggables<CR>', 'Debuggables' },
                    e = { ':RustLsp explainError<CR>', 'Explain Error' },
                    c = { ':RustLsp openCargo<CR>', 'Open Cargo.toml' },
                    g = { ':RustLsp crateGraph<CR>', 'View Crate Graph' },
                    m = { ':RustLsp expandMacro<CR>', 'Expand Macro' },
                    p = { ':RustLsp parentModule<CR>', 'Parent Module' },
                    j = { ':RustLsp joinLines<CR>', 'Join Lines' },
                    a = { ':RustLsp hover actions<CR>', 'Hover Actions' },
                    h = { ':RustLsp hover range<CR>', 'Range Hover Actions' },
                    b = { ':RustLsp moveItem down<CR>', 'Move Item Down' },
                    u = { ':RustLsp moveItem up<CR>', 'Move Item Up' },
                    s = { ':RustLsp syntaxTree<CR>', 'View Syntax Tree' },
                    t = { '<cmd>require("setup.toggleterm").run_float("cargo test")<CR>', 'Run tests' },
                },
                j = {
                    name = 'Java',
                    a = { '<cmd>lua require("jdtls").code_action()', 'Code Action' },
                    r = { '<cmd>lua require("jdtls").code_action(false, "refactor")', 'Refactor' },
                    o = { '<cmd>lua require("jdtls").organize_imports()', 'Organize Imports' },
                    e = { '<cmd>lua require("jdtls").extract_variable()', 'Extract Variable' },
                    c = { '<cmd>lua require("jdtls").extract_constant()', 'Extract Constant' },
                    m = { '<cmd>lua require("jdtls").extract_method()', 'Extract Method' },
                    t = { '<cmd>lua require("jdtls").test_class()', 'Test Class' },
                    n = { '<cmd>lua require("jdtls").test_nearest_method()', 'Test Nearest Method' },
                },
                s = {
                    name = 'Shell',
                    a = { ':ToggleTermOpenAll<CR>', 'Open All' },
                    c = { ':ToggleTermCloseAll<CR>', 'Open All' },
                    h = { ':ToggleTerm direction=horizontal<CR>', 'Horizontal' },
                    v = { ':ToggleTerm direction=vertical<CR>', 'Vertical' },
                    f = { ':ToggleTerm direction=float<CR>', 'Float' },
                },
                a = {
                    name = 'Aerial',
                    t = { ':AerialToggle<CR>', 'Toggle' },
                    a = { ':AerialOpenAll<CR>', 'Open All' },
                    c = { ':AerialCloseAll<CR>', 'Close All' },
                    s = { ':AerialTreeSyncFolds<CR>', 'Sync code folding' },
                    i = { ':AerialInfo<CR>', 'Info' },
                },
                o = {
                    name = 'Overseer',
                    t = { '<cmd>lua require("sidebar"):toggle("overseer")<CR>', 'Toggle' },
                    s = { ':OverseerSaveBundle<CR>', 'Save' },
                    l = { ':OverseerLoadBundle<CR>', 'Load' },
                    d = { ':OverseerDeleteBundle<CR>', 'Delete' },
                    c = { ':OverseerRunCmd<CR>', 'Run shell command' },
                    r = { ':OverseerRun<CR>', 'Run task' },
                    b = { ':OverseerBuild<CR>', 'Open task builder' },
                    q = { ':OverseerQuickAction<CR>', 'Run action on a task' },
                    a = { ':OverseerTaskAction<CR>', 'Select a task to run an action on' },
                },
                n = {
                    name = 'Refactoring',
                    i = { ':Refactor inline_var', 'Inline Variable' },
                    I = { ':Refactor inline_func', 'Inline Function' },
                    b = { ':Refactor extract_block', 'Extract Block' },
                    f = { ':Refactor extract_block_to_file', 'Extract Block to File' },
                    r = { '<cmd>lua require("telescope").extensions.refactoring.refactors()<CR>', 'Refactors' },
                    p = { '<cmd>lua require("refactoring").debug.printf()<CR>', 'Printf' },
                    v = { '<cmd>lua require("refactoring").debug.print_var()<CR>', 'Print Variable' },
                    c = { '<cmd>lua require("refactoring").debug.cleanup({})<CR>', 'Cleanup' },
                },
            },
            opts = {
                prefix = '<leader>',
                noremap = true,
                silent = true,
                mode = 'n',
            },
        },
    },
    map_keys = function()
        for _, keymap in pairs(keymap_table) do
            if keymap.enabled then
                local opts = vim.tbl_extend('force', { desc = keymap.description }, keymap.opts)
                vim.keymap.set(keymap.modes, keymap.shortcut, keymap.cmd, opts)
            end
        end
    end,
}
