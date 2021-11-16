-- default shell
-- vim.o.shell= '/bin/fish'
-- secure modelines
vim.g.secure_modelines_allowed_items = {
    'textwidth',
    'tw',
    'softtabstop',
    'sts',
    'tabstop',
    'ts',
    'shiftwidth',
    'sw',
    'expandtab',
    'et',
    'noexpandtab',
    'noet',
    'filetype',
    'ft',
    'foldmethod',
    'fdm',
    'readonly',
    'ro',
    'noreadonly',
    'noro',
    'rightleft',
    'rl',
    'norightleft',
    'norl',
    'colorcolumn',
}

-- Do not source the default filetype.vim TODO: remove after nvim 0.6
vim.g.did_load_filetypes = 1

-- replace grep with rg
vim.go.grepprg = 'rg --no-heading --vimgrep'
vim.go.grepformat = '%f:%l:%c:%m'

-- Don't confirm .lvimrc
vim.g.localvimrc_ask = 0

-- size of cmd bar
vim.go.cmdheight = 2
-- You will have bad experience for diagnostic messages when it's default 4000.
vim.go.updatetime = 300

-- Editor settings
vim.cmd('filetype plugin indent on')
vim.o.autoindent = true
vim.o.timeoutlen = 300 -- http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
vim.o.encoding = 'utf-8'
vim.o.scrolloff = 2
vim.o.showmode = false
vim.o.hidden = true
vim.o.wrap = false
vim.o.joinspaces = false
vim.o.printfont = ':h10'
vim.o.printencoding = 'utf-8'
vim.o.printoptions = 'paper:letter'
-- Always draw sign column. Prevent buffer moving when adding/deleting sign.
vim.o.signcolumn = 'yes'

-- Settings needed for .lvimrc
vim.o.exrc = true
vim.o.secure = true

-- Sane splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Permanent undo
vim.o.undodir = os.getenv('HOME') .. '/.vimdid'
vim.o.undofile = true

-- Decent wildmenu
vim.o.wildmenu = true
vim.o.wildmode = 'list:longest'
vim.o.wildignore =
    '.hg,.svn,*~,*.png,*.jpg,*.gif,*.settings,Thumbs.db,*.min.js,*.swp,publish/*,intermediate/*,*.o,*.hi,Zend,vendor,*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite'

-- Use wide tabs
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4
vim.o.expandtab = true

-- Backspace over newline
vim.o.backspace = 'indent,eol,start'

-- Wrapping options
vim.o.formatoptions = 'tc' -- wrap text and comments using textwidth
vim.o.formatoptions = vim.o.formatoptions .. 'r' -- continue comments when pressing ENTER in I mode
vim.o.formatoptions = vim.o.formatoptions .. 'q' -- enable formatting of comments with gq
vim.o.formatoptions = vim.o.formatoptions .. 'n' -- detect lists for formatting
vim.o.formatoptions = vim.o.formatoptions .. 'b' -- auto-wrap in insert mode, and do not wrap old long lines

-- Proper search
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true

-- session management
require('auto-session').setup({
    auto_save_enabled = true,
    auto_restore_enabled = true,
    auto_session_enable_last_session = false,
    auto_session_allowed_dirs = { os.getenv('HOME') .. '/projects' },
})
require('session-lens').setup({})
vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,resize,winpos,terminal'

-- Abbreviations
vim.cmd('cnoreabbrev W! w!')
vim.cmd('cnoreabbrev Q! q!')
vim.cmd('cnoreabbrev Qall! qall!')
vim.cmd('cnoreabbrev Wq wq')
vim.cmd('cnoreabbrev Wa wa')
vim.cmd('cnoreabbrev wQ wq')
vim.cmd('cnoreabbrev WQ wq')
vim.cmd('cnoreabbrev W w')
vim.cmd('cnoreabbrev Q q')
vim.cmd('cnoreabbrev Qall qall')

-- Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force user to select one from the menu
vim.o.completeopt = 'menuone,noinsert,noselect'

-- No whitespace in vimdiff
vim.o.diffopt = vim.o.diffopt .. ',iwhite'
-- Make diffing better: https://vimways.org/2018/the-power-of-diff/
vim.o.diffopt = vim.o.diffopt .. ',algorithm:patience'
vim.o.diffopt = vim.o.diffopt .. ',indent-heuristic'

-- Avoid showing extra messages when using completion
vim.o.shortmess = vim.o.shortmess .. 'c'
-- remove trailing whitespaces
vim.cmd('command! FixWhitespace :%s/\\s\\+$//e')

-- automatic reload file on buffer changed outside of vim
vim.o.autoread = true

-- Show those damn hidden characters
-- Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
vim.o.listchars = 'nbsp:¬,extends:»,precedes:«,trail:•'

-- Show problematic characters.
vim.o.list = true

-- Also highlight all tabs and trailing whitespace characters.
vim.cmd('highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen')
vim.cmd('match ExtraWhitespace /\\s\\+$\\|\\t/')

-- Nvim Tree settings
vim.g.nvim_tree_quit_on_open = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_highlight_opened_files = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_disable_window_picker = 1
vim.g.nvim_tree_window_picker_exclude = {
    filetype = { 'notify', 'packer', 'qf' },
    buftype = { 'terminal' },
}
require('nvim-tree').setup({
    auto_open = false,
    auto_close = true,
    diagnostics = {
        enable = true,
    },
    filters = {
        custom = { '.rbc$', '~$', '.pyc$', '.db$', '.sqlite$', '__pycache__', '.git', '.cache' },
    },
})

-- banlkline
require('indent_blankline').setup({
    char = '|',
    filetype_exclude = { 'packer' },
    buftype_exclude = { 'terminal' },
})

-- Tabline
-- Set barbar's options
vim.g.bufferline = {
    animation = true,
    auto_hide = false,
    tabpages = true,
    closable = true,
    -- left-click: go to buffer
    -- middle-click: delete buffer
    clickable = true,
    -- if set to 'numbers', will show buffer index in the tabline
    -- if set to 'both', will show buffer index and icons in the tabline
    icons = 'both',
    icon_separator_active = '▎',
    icon_separator_inactive = '▎',
    icon_close_tab = '',
    icon_close_tab_modified = '●',
    icon_pinned = '車',
    insert_at_end = true,
    maximum_padding = 1,
    maximum_length = 30,
    -- If set, the letters for each buffer in buffer-pick mode will be
    -- assigned based on their name. Otherwise or in case all letters are
    -- already assigned, the behavior is to assign letters in order of
    -- usability (see order below)
    semantic_letters = true,
    -- New buffer letters are assigned in this order. This order is
    -- optimal for the qwerty keyboard layout but might need adjustement
    -- for other layouts.
    letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',
}

-- enable virtual text for debugging
require('nvim-dap-virtual-text').setup({
    all_frames = true,
})

-- surround
require('surround').setup({
    brackets = { '(', '{', '[', '<' },
    pairs = {
        nestable = { { '(', ')' }, { '{', '}' }, { '[', ']' }, { '<', '>' } },
        linear = { { '"', '"' }, { "'", "'" }, { 'r#"', '"#' } },
    },
    mappings_style = 'sandwich',
    surround_map_insert_mode = false,
})

-- hop tree-sitter integration
local hint = require('hop.hint')
hint.treesitter_queries(query, inners, outers, queryfile)
hint.treesitter_locals()

-- todo comments config
require('todo-comments').setup({
    signs = false,
    highlight = {
        comments_only = true,
    },
    search = {
        command = 'rg',
        args = {
            '--max-depth=10',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
        },
    },
})

require('sidebar-nvim').setup({
    open = false,
    side = 'left',
    initial_width = 30,
    update_interval = 1000,
    sections = { 'git-status', 'lsp-diagnostics', 'todos', 'containers' },
    ignored_paths = { '~' },
})

-- Telescope
require('telescope').setup({
    defaults = {
        file_previewer = require('telescope.previewers').cat.new,
        grep_previewer = require('telescope.previewers').vimgrep.new,
        qflist_previewer = require('telescope.previewers').qflist.new,
    },
})
require('telescope').load_extension('fzf')
require('telescope').load_extension('lsp_handlers')
require('telescope').load_extension('dap')
require('telescope').load_extension('session-lens')

require('filetype').setup({
    overrides = {
        complex = {
            ['Dockerfile*'] = 'dockerfile',
            -- Set the filetype of any full filename matching the regex to gitconfig
            ['.*git/config'] = 'gitconfig', -- Included in the plugin
        },
    },
})
require('Comment').setup({
    ignore = '^$',
})

-- Neovide settings
vim.g.neovide_no_idle = true
vim.g.neovide_input_use_logo = true
vim.g.neovide_cursor_antialiasing = true
