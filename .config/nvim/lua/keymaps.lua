-- IMPORTANT: check cmp.lua for auto complete keymaps
-- leader keys
vim.g.mapleader = ' '
vim.o.timeoutlen = 500

local wk = require("which-key")

local keymap = vim.api.nvim_set_keymap
local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

local no_remap_opt = { noremap = true }
local silent_opt = { silent = true }
local no_remap_silent_opt = { noremap = true, silent = true }

-- Visual Multi Cursors
-- keymap('n', '<M-Down>' '<Plug>(VM-Add-Cursor-Down)', no_remap_opt)
-- keymap('n', '<M-Up>' '<Plug>(VM-Add-Cursor-Up)', no_remap_opt)

-- Increment/decrement
keymap('n', '+', '<C-a>', no_remap_opt)
keymap('n', '-', '<C-x>', no_remap_opt)

-- Select all
keymap('n', '<C-a>', 'gg<S-v>G', {})

-- Open hotkeys
keymap('n', '<M-p>', '<cmd>lua require("fzf-lua").buffers()<CR>', no_remap_silent_opt)
keymap('n', '<C-p>', '<cmd>lua require("fzf-lua").files()<CR>', no_remap_silent_opt)

wk.register({
    f = {
        name = 'File',
        b = {'<cmd>lua require("fzf-lua").buffers()<CR>', 'Buffers' },
        f = {'<cmd>lua require("fzf-lua").files()<CR>', 'Files' },
        r = {'<cmd>lua require("fzf-lua").files_resume()<CR>', 'Resume Query' },
        o = {'<cmd>lua require("fzf-lua").oldfiles()<CR>', 'Opened Files History' },
        q = {'<cmd>lua require("fzf-lua").quickfix()<CR>', 'Quickfix List' },
        l = {'<cmd>lua require("fzf-lua").loclist()<CR>', 'Location List' },
        s = {'<cmd>lua require("fzf-lua").lines()<CR>', 'Open Buffers Lines' },
        b = {'<cmd>lua require("fzf-lua").blines()<CR>', 'Current Buffer Lines' },
    },
    p = {
        name = 'Grep',
        g = {'<cmd>lua require("fzf-lua").grep()<CR>', 'Grep' },
        l = {'<cmd>lua require("fzf-lua").grep_last()<CR>', 'Grep Last Pattern' },
        c = {'<cmd>lua require("fzf-lua").grep_cword()<CR>', 'Grep word Under Cursor' },
        w = {'<cmd>lua require("fzf-lua").grep_cWORD()<CR>', 'Grep WORD Under Cursor' },
        v = {'<cmd>lua require("fzf-lua").grep_visual()<CR>', 'Grep Visual' },
        b = {'<cmd>lua require("fzf-lua").grep_curbuf()<CR>', 'Live Grep Current Buffer' },
        p = {'<cmd>lua require("fzf-lua").live_grep()<CR>', 'Live Grep Current Project' },
        r = {'<cmd>lua require("fzf-lua").live_grep_resume()<CR>', 'Live Grep Resume' },
    },
    g = {
        name = 'Git',
        f = {'<cmd>lua require("fzf-lua").git_files()<CR>', 'Files' },
        s = {'<cmd>lua require("fzf-lua").git_status()<CR>', 'Status' },
        c = {'<cmd>lua require("fzf-lua").git_commits()<CR>', 'Commit Log' },
        l = {'<cmd>lua require("fzf-lua").git_bcommits()<CR>', 'Commit Log Current Buffer' },
        b = {'<cmd>lua require("fzf-lua").git_branches()<CR>', 'Branches' },
    },
    l = {
        name = 'LSP',
        r = {'<cmd>lua require("fzf-lua").lsp_references()<CR>', 'References' },
        d = {'<cmd>lua require("fzf-lua").lsp_definitions()<CR>', 'Definitions' },
        n = {'<cmd>lua require("fzf-lua").lsp_declarations()<CR>', 'Declarations' },
        t = {'<cmd>lua require("fzf-lua").lsp_typedefs()<CR>', 'Type Definitions' },
        i = {'<cmd>lua require("fzf-lua").lsp_implementations()<CR>', 'Implementations' },
        s = {'<cmd>lua require("fzf-lua").lsp_document_symbols()<CR>', 'Document Symbols' },
        w = {'<cmd>lua require("fzf-lua").lsp_workspace_symbols()<CR>', 'Workspace Symbols' },
        v = {'<cmd>lua require("fzf-lua").lsp_live_workspace_symbols()<CR>', 'Live Workspace Symbols' },
        a = {'<cmd>lua require("fzf-lua").lsp_code_actions()<CR>', 'Code Actions' },
        l = {'<cmd>FzfLua lua vim.lsp.codelens.display()<CR>', 'Code Lens' },
        g = {'<cmd>lua require("fzf-lua").lsp_document_diagnostics()<CR>', 'Document Diagnostics' },
        o = {'<cmd>lua require("fzf-lua").lsp_workspace_diagnostics()<CR>', 'Workspace Diagnostics' },
    },
    m = {
        name = 'Misc',
        s = {'<cmd>lua require("fzf-lua").spelling_suggestions()<CR>', 'Spelling Suggestions' },
        c = {'<cmd>lua require("fzf-lua").commands()<CR>', 'Neovim Commands' },
        h = {'<cmd>lua require("fzf-lua").command_history()<CR>', 'Command History' },
        y = {'<cmd>lua require("fzf-lua").search_history()<CR>', 'Search History' },
        m = {'<cmd>lua require("fzf-lua").marks()<CR>', 'Marks' },
        r = {'<cmd>lua require("fzf-lua").registers()<CR>', 'Registers' },
        k = {'<cmd>lua require("fzf-lua").keymaps()<CR>', 'Keymaps' },
    },
    r = {
        name = 'Rust',
        r = {':RustRunnables<CR>', 'Runnables' },
        d = {':RustDebuggables<CR>', 'Debuggables' },
        e = {':RustExpandMacro<CR>', 'Expand Macro' },
        c = {':RustOpenCargo<CR>', 'Open Cargo.toml' },
        g = {':RustViewCrateGraph<CR>', 'View Crate Graph' },
        m = {':RustParentModule<CR>', 'Parent Module' },
        j = {':RustJoinLines<CR>', 'Join Lines' },
        a = {':RustHoverActions<CR>', 'Hover Actions' },
        h = {':RustHoverRange<CR>', 'Range Hover Actions' },
        b = {':RustMoveItemDown<CR>', 'Move Item Down' },
        u = {':RustMoveItemUp<CR>', 'Move Item Up' },
        s = {':RustStartStandaloneServerForBuffer<CR>', 'New Server for Buffer' },
    }
}, { prefix = '<leader>', noremap = true, silent = true })

-- Copy visually selected text to system clipboard
keymap('x', '<leader>c', '"*y', {})

-- Search results centered please
keymap('n', 'n', 'nzz', no_remap_silent_opt)
keymap('n', 'N', 'Nzz', no_remap_silent_opt)
keymap('n', '*', '*zz', no_remap_silent_opt)
keymap('n', '#', '#zz', no_remap_silent_opt)
keymap('n', 'g*', 'g*zz', no_remap_silent_opt)

-- Very magic by default
keymap('n', '?', '?\\v', no_remap_opt)
keymap('n', '/', '/\\v', no_remap_opt)
keymap('c', '%s/', '%sm/', no_remap_opt)

-- NvimTree
function _tree_find()
    require'bufferline.state'.set_offset(31, 'FileTree')
    require'nvim-tree'.find_file(true)
end
function _tree_toggle()
    if require'nvim-tree.view'.win_open() then
        require'bufferline.state'.set_offset(0)
    else
        require'bufferline.state'.set_offset(31, 'FileTree')
    end
    require'nvim-tree'.toggle()
end
keymap('n', '<F2>', '<cmd>lua _tree_find()<CR>', no_remap_opt)
keymap('n', '<F3>', '<cmd>lua _tree_toggle()<CR>', no_remap_opt)

-- terminal
-- lazygit
local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({ 
    cmd = "lazygit",
    hidden = true,
    direction = "float",
    on_open = function(term)
        vim.cmd("startinsert!")
        buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", no_remap_silent_opt)
    end,
})

function _lazygit_toggle()
  lazygit:toggle()
end

wk.register({
    s = {
        name = 'Shell',
        a = {':ToggleTermOpenAll<CR>', 'Open All' },
        c = {':ToggleTermCloseAll<CR>', 'Open All' },
        h = {':ToggleTerm<CR>', 'Horizontal' },
        v = {':ToggleTerm direction=vertical<CR>', 'Vertical' },
        f = {':ToggleTerm direction=float<CR>', 'Float' },
        g = {'<cmd>lua _lazygit_toggle()<CR>', 'Lazy Git' },
    },
}, { prefix = "<leader>", noremap = true, silent = true })

-- close current buffer without closing window
keymap('n', '<C-x>', ':BufferClose<CR>', no_remap_opt)

-- Left and right can switch buffers
keymap('n', '<leader><left>', ':BufferPrevious<CR>', no_remap_opt)
keymap('n', '<leader><right>', ':BufferNext<CR>', no_remap_opt)
keymap('n', '<M><left>', ':BufferMovePrevious<CR>', no_remap_opt)
keymap('n', '<M><right>', ':BufferMoveNext<CR>', no_remap_opt)
keymap('n', '<M-1>', ':BufferGoto 1<CR>', no_remap_opt)
keymap('n', '<M-2>', ':BufferGoto 2<CR>', no_remap_opt)
keymap('n', '<M-3>', ':BufferGoto 3<CR>', no_remap_opt)
keymap('n', '<M-4>', ':BufferGoto 4<CR>', no_remap_opt)
keymap('n', '<M-5>', ':BufferGoto 5<CR>', no_remap_opt)
keymap('n', '<M-6>', ':BufferGoto 6<CR>', no_remap_opt)
keymap('n', '<M-7>', ':BufferGoto 7<CR>', no_remap_opt)
keymap('n', '<M-8>', ':BufferGoto 8<CR>', no_remap_opt)
keymap('n', '<M-9>', ':BufferGoto 9<CR>', no_remap_opt)
keymap('n', '<M-0>', ':BufferLast<CR>', no_remap_opt)
keymap('n', '<M-i>', ':BufferPick<CR>', no_remap_opt)

-- Ctrl+h to stop searching
keymap('v', '<C-h>', ':nohlsearch<CR>', no_remap_opt)
keymap('n', '<C-h>', ':nohlsearch<CR>', no_remap_opt)


-- Jump to start and end of line using the home row keys
keymap('v', 'H', '^', {})
keymap('n', 'H', '^', {})
keymap('v', 'L', '$', {})
keymap('n', 'L', '$', {})

-- In insert or command mode, move normally by using Ctrl
keymap('i', '<C-h>', '<Left>', no_remap_opt)
keymap('i', '<C-j>', '<Down>', no_remap_opt)
keymap('i', '<C-k>', '<Up>', no_remap_opt)
keymap('i', '<C-l>', '<Right>', no_remap_opt)
keymap('c', '<C-h>', '<Left>', no_remap_opt)
keymap('c', '<C-j>', '<Down>', no_remap_opt)
keymap('c', '<C-k>', '<Up>', no_remap_opt)
keymap('c', '<C-l>', '<Right>', no_remap_opt)

-- Move between windows with arrow keys
keymap('n', '<left>', '<C-w><left>', no_remap_opt)
keymap('n', '<right>', '<C-w><right>', no_remap_opt)
keymap('n', '<up>', '<C-w><up>', no_remap_opt)
keymap('n', '<down>', '<C-w><down>', no_remap_opt)

-- Delete on insert mode
keymap('i', '<C-d>', '<C-o>x', no_remap_opt)

-- shows/hides hidden characters
keymap('n', '<leader>,', ':set invlist<CR>', no_remap_opt)

-- I can type :help on my own, thanks.
keymap('n', '<F1>', '<Esc>', {})
keymap('i', '<F1>', '<Esc>', {})
keymap('c', '<F1>', '<Esc>', {})
keymap('v', '<F1>', '<Esc>', {})
keymap('t', '<F1>', '<Esc>', {})

-- save
keymap('n', '<C-s>', ':wa<CR>', no_remap_opt)
keymap('i', '<C-s>', '<C-o>:wa<CR>', no_remap_opt)

-- Goto previous/next diagnostic warning/error
-- Use `[g` and `]g` to navigate diagnostics
keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', silent_opt)
keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', silent_opt)

-- GoTo code navigation
keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', silent_opt)
keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', silent_opt)
keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', silent_opt)
keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', silent_opt)
keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', silent_opt)

-- Documentation
keymap('i', '<M-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', silent_opt)
-- calling twice make the cursor go into the float window. good for navigating big docs
keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover() vim.lsp.buf.hover()<CR>', silent_opt)

-- Refactor rename
keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', silent_opt)

-- Code action
keymap('n', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', {})
keymap('n', '<leader>x', '<cmd>lua vim.lsp.codelens.run()<CR>', {})
keymap('x', '<leader>a', '<cmd>lua vim.lsp.buf.range_code_action()<CR>', {})
keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', silent_opt)
keymap("n", "<M-f>", "<cmd>lua vim.lsp.buf.formatting()<CR>", silent_opt)
keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', silent_opt)

-- Debug Mappings
keymap('n', '<F4>', ':lua require"dap".repl.toggle()', silent_opt)
keymap('n', '<F5>', ':lua require"dap".continue()', silent_opt)
keymap('n', '<S-F5>', ':lua require"dap".close()', silent_opt)
keymap('n', '<C-S-F5>', ':lua require"dap".run_last()', silent_opt)
keymap('n', '<F6>', ':lua require"dap".pause()', silent_opt)
keymap('n', '<F9>', ':lua require"dap".toggle_breakpoint()', silent_opt)
keymap('n', '<S-F9>', ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))', silent_opt)
keymap('n', '<leader><F9>', ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))', silent_opt)
keymap('n', '<F10>', ':lua require"dap".step_over()', silent_opt)
keymap('n', '<S-F10>', ':lua require"dap".run_to_cursor()', silent_opt)
keymap('n', '<F11>', ':lua require"dap".step_into()', silent_opt)
keymap('n', '<S-F11>', ':lua require"dap".step_out()', silent_opt)
keymap('x', '<leader>e', ':lua require("dap.ui.widgets").hover()', silent_opt)
