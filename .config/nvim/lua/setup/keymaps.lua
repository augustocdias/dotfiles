local no_remap_opt = { noremap = true }
local silent_opt = { silent = true }
local no_remap_silent_opt = { noremap = true, silent = true }

local sidebar = require('sidebar')
local gitsigns = require('gitsigns')

local keymap_table = {
    {
        shortcut = 's',
        cmd = function()
            require('flash').jump()
        end,
        opts = no_remap_opt,
        modes = { 'n', 'x', 'o' },
        description = 'Flash',
    },
    {
        shortcut = 'S',
        cmd = function()
            require('flash').treesitter()
        end,
        opts = no_remap_opt,
        modes = { 'n', 'x', 'o' },
        description = 'Flash Treesitter',
    },
    {
        shortcut = 'r',
        cmd = function()
            require('flash').remote()
        end,
        opts = no_remap_opt,
        modes = { 'o' },
        description = 'Flash Remote',
    },
    {
        shortcut = 'R',
        cmd = function()
            require('flash').treesitter_search()
        end,
        opts = no_remap_opt,
        modes = { 'x', 'o' },
        description = 'Flash Treesitter Search',
    },
    {
        shortcut = ']c',
        cmd = function()
            if vim.wo.diff then
                return ']c'
            end
            vim.schedule(function()
                gitsigns.next_hunk()
            end)
            return '<Ignore>'
        end,
        opts = { expr = true },
        modes = { 'n' },
        description = 'Next git hunk',
    },
    {
        shortcut = '[c',
        cmd = function()
            if vim.wo.diff then
                return '[c'
            end
            vim.schedule(function()
                gitsigns.prev_hunk()
            end)
            return '<Ignore>'
        end,
        opts = { expr = true },
        modes = { 'n' },
        description = 'Previous git hunk',
    },
    {
        shortcut = '+',
        cmd = '<C-a>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Increment number',
    },
    {
        shortcut = '-',
        cmd = '<C-x>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Decrement number',
    },
    {
        shortcut = '<C-a>',
        cmd = 'gg<S-v>G',
        opts = {},
        modes = { 'n' },
        description = 'Select all',
    },
    {
        shortcut = '<M-p>',
        cmd = require('telescope.builtin').buffers,
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Open buffers',
    },
    {
        shortcut = '<C-p>',
        cmd = require('telescope.builtin').find_files,
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Open file in workspace',
    },
    {
        shortcut = '<M-r>',
        cmd = ':e!<CR>',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Refresh buffer',
    },
    {
        shortcut = '<M-w>',
        cmd = require('auto-session.session-lens').search_session,
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Open saved session',
    },
    {
        shortcut = '<M-t>',
        cmd = ':TroubleToggle workspace_diagnostics<CR>',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Show diagnostics pane',
    },
    {
        shortcut = 'n',
        cmd = 'nzz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
    },
    {
        shortcut = 'N',
        cmd = 'Nzz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
    },
    {
        shortcut = '*',
        cmd = '*zz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
    },
    {
        shortcut = '#',
        cmd = '#zz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
    },
    {
        shortcut = 'g*',
        cmd = 'g*zz',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Center search navigation',
    },
    { shortcut = '?',   cmd = '?\\v', opts = no_remap_opt, modes = { 'n' }, description = 'Improve search' },
    { shortcut = '/',   cmd = '/\\v', opts = no_remap_opt, modes = { 'n' }, description = 'Improve search' },
    { shortcut = '\\',  cmd = '/@',   opts = no_remap_opt, modes = { 'n' }, description = 'Improve search' },
    { shortcut = '%s/', cmd = '%sm/', opts = no_remap_opt, modes = { 'c' }, description = 'Improve search' },
    {
        shortcut = '<F2>',
        cmd = function()
            require('oil').toggle_float()
        end,
        -- cmd = function()
        --     sidebar:toggle('neotree')
        -- end,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Toggle File Manager',
    },
    {
        shortcut = '<C-x>',
        cmd = ':lua MiniBufremove.delete()<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Close current buffer',
    },
    {
        shortcut = '<M><left>',
        cmd = '<Plug>(SpotifyPrev)<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Previous Song (Spotify)',
    },
    {
        shortcut = '<M><right>',
        cmd = '<Plug>(SpotifySkip)<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Next Song (Spotify)',
    },
    {
        shortcut = '<M-/>',
        cmd = '<Plug>(SpotifyPause)<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Pause (Spotify)',
    },
    {
        shortcut = '<C-g>',
        cmd = ':nohlsearch<CR>',
        opts = no_remap_opt,
        modes = { 'n', 'v' },
        description = 'Clear search',
    },
    { shortcut = 'H', cmd = '^', opts = {}, modes = { 'n', 'v' }, description = 'Jump to start of the line' },
    { shortcut = 'L', cmd = '$', opts = {}, modes = { 'n', 'v' }, description = 'Jump to end of the line' },
    {
        shortcut = '<C-h>',
        cmd = '<Left>',
        opts = no_remap_opt,
        modes = { 'i', 'c' },
        description = 'Move cursor left',
    },
    {
        shortcut = '<C-j>',
        cmd = '<Down>',
        opts = no_remap_opt,
        modes = { 'i', 'c' },
        description = 'Move cursor down',
    },
    {
        shortcut = '<C-k>',
        cmd = '<Up>',
        opts = no_remap_opt,
        modes = { 'i', 'c' },
        description = 'Move cursor up',
    },
    {
        shortcut = '<C-l>',
        cmd = '<Right>',
        opts = no_remap_opt,
        modes = { 'i', 'c' },
        description = 'Move cursor right',
    },
    {
        shortcut = '<C-h>',
        cmd = '<C-w><left>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Focus on window to the left',
    },
    {
        shortcut = '<C-l>',
        cmd = '<C-w><right>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Focus on window to the right',
    },
    {
        shortcut = '<C-k>',
        cmd = '<C-w><up>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Focus on window up',
    },
    {
        shortcut = '<C-j>',
        cmd = '<C-w><down>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Focus on window down',
    },
    {
        shortcut = '<right>',
        cmd = '<CMD>vertical resize +2<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Increase window width',
    },
    {
        shortcut = '<left>',
        cmd = '<CMD>vertical resize -2<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Decrease window width',
    },
    {
        shortcut = '<up>',
        cmd = '<CMD>resize +2<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Increase window height',
    },
    {
        shortcut = '<down>',
        cmd = '<CMD>resize -2<CR>',
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Decrease window height',
    },
    {
        shortcut = '<C-d>',
        cmd = '<C-o>x',
        opts = no_remap_opt,
        modes = { 'i' },
        description = 'Delete char forward in insert mode',
    },
    {
        shortcut = '<F1>',
        cmd = function()
            sidebar:toggle('sidebar')
        end,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Toggle sidebar',
    },
    {
        shortcut = '<C-s>',
        cmd = ':wa<CR>',
        opts = no_remap_silent_opt,
        modes = { 'n' },
        description = 'Savel all',
    },
    {
        shortcut = '<C-s>',
        cmd = '<C-o>:wa<CR>',
        opts = no_remap_silent_opt,
        modes = { 'i' },
        description = 'Savel all',
    },
    {
        shortcut = '[g',
        cmd = vim.diagnostic.goto_prev,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Go to previous diagnostic',
    },
    {
        shortcut = ']g',
        cmd = vim.diagnostic.goto_next,
        opts = no_remap_opt,
        modes = { 'n' },
        description = 'Go to next diagnostic',
    },
    {
        shortcut = 'gx',
        cmd = '<CMD>Browse<CR>',
        opts = silent_opt,
        modes = { 'n', 'x' },
        description = 'Open links in browser',
    },
    {
        shortcut = 'gD',
        cmd = vim.lsp.buf.declaration,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Go to declaration',
    },
    {
        shortcut = 'gt',
        cmd = vim.lsp.buf.type_definition,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Go to type definition',
    },
    {
        shortcut = 'gd',
        cmd = vim.lsp.buf.definition,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Go to definition',
    },
    {
        shortcut = 'gi',
        cmd = vim.lsp.buf.implementation,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Go to implementation',
    },
    {
        shortcut = 'gr',
        cmd = function()
            vim.lsp.buf.references({ includeDeclaration = false })
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Find references',
    },
    {
        shortcut = '<M-k>',
        cmd = vim.lsp.buf.signature_help,
        opts = silent_opt,
        modes = { 'i' },
        description = 'Signature help',
    },
    {
        shortcut = '<M-k>',
        cmd = vim.lsp.buf.signature_help,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Signature help',
    },
    -- call twice make the cursor go into the float window. good for navigating big docs
    {
        shortcut = 'K',
        cmd = vim.lsp.buf.hover,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Show hover popup',
    },
    {
        shortcut = '<M-f>',
        cmd = function()
            vim.lsp.buf.format({ async = false })
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'Format code',
    },
    {
        shortcut = '<F4>',
        cmd = require('dap').repl.toggle,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Toggle repl',
    },
    {
        shortcut = '<F5>',
        cmd = require('dap').continue,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Continue',
    },
    {
        shortcut = '<S-F5>',
        cmd = require('dap').close,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Stop',
    },
    {
        shortcut = '<C-F5>',
        cmd = require('dap').run_last,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Run last',
    },
    {
        shortcut = '<F6>',
        cmd = require('dap').pause,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Pause',
    },
    {
        shortcut = '<F9>',
        cmd = require('dap').toggle_breakpoint,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Toggle breakpoint',
    },
    {
        shortcut = '<S-F9>',
        cmd = function()
            require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Set breakpoint with condition',
    },
    {
        shortcut = '<C-F9>',
        cmd = function()
            require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
        end,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Set logpoint',
    },
    {
        shortcut = '<F10>',
        cmd = require('dap').step_over,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Step over',
    },
    {
        shortcut = '<S-F10>',
        cmd = require('dap').run_to_cursor,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Run to cursor',
    },
    {
        shortcut = '<F11>',
        cmd = require('dap').step_into,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Step into',
    },
    {
        shortcut = '<S-F11>',
        cmd = require('dap').step_out,
        opts = silent_opt,
        modes = { 'n' },
        description = 'DAP Step out',
    },
    {
        shortcut = '<F7>',
        cmd = require('dap.ui.widgets').hover,
        opts = silent_opt,
        modes = { 'x' },
        description = 'DAP Hover',
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
                    s = { '<cmd>lua require("spectre").open()<CR>', 'Spectre' },
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
                    g = { '<cmd>lua require("setup.neotree").neogit("git")<CR>', 'Neo-tree git' },
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
                    name = 'Debug Adapter',
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
            local opts = vim.tbl_extend('force', { desc = keymap.description }, keymap.opts)
            vim.keymap.set(keymap.modes, keymap.shortcut, keymap.cmd, opts)
        end
    end,
}
