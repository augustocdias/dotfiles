-- enables experimental lua loader
vim.loader.enable()

-- map leader to space
vim.g.mapleader = ' '
-- vim.g.maplocalleader = '='
-- timeout for leader key
vim.o.timeoutlen = 500
-- default shell
vim.o.shell = '/opt/homebrew/bin/fish'
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

-- replace grep with rgsettings
vim.go.grepprg = 'rg --no-heading --vimgrep'
vim.go.grepformat = '%f:%l:%c:%m'

-- Don't confirm .lvimrc
vim.g.localvimrc_ask = 0

-- size of cmd bar
vim.go.cmdheight = 2
-- You will have bad experience for diagnostic messages when it's default 4000.
vim.go.updatetime = 100

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
vim.o.conceallevel = 3
vim.o.concealcursor = 'n'
-- current line will have a background
vim.o.cursorline = true
-- Always draw sign column. Prevent buffer moving when adding/deleting sign.
vim.o.signcolumn = 'yes'

-- folding
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

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
vim.o.formatoptions = 'tc'                       -- wrap text and comments using textwidth
vim.o.formatoptions = vim.o.formatoptions .. 'r' -- continue comments when pressing ENTER in I mode
vim.o.formatoptions = vim.o.formatoptions .. 'q' -- enable formatting of comments with gq
vim.o.formatoptions = vim.o.formatoptions .. 'n' -- detect lists for formatting
vim.o.formatoptions = vim.o.formatoptions .. 'b' -- auto-wrap in insert mode, and do not wrap old long lines

-- Proper search
vim.o.incsearch = true
vim.o.inccommand = 'split'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true

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

-- No whitespace in vimdiff
vim.o.diffopt = vim.o.diffopt .. ',iwhite'
-- Make diffing better: https://vimways.org/2018/the-power-of-diff/
vim.o.diffopt = vim.o.diffopt .. ',algorithm:patience'
vim.o.diffopt = vim.o.diffopt .. ',indent-heuristic'
-- https://github.com/neovim/neovim/pull/14537
vim.o.diffopt = vim.o.diffopt .. ',linematch:50'

-- shortmess
-- I -> don't show intro message
-- O -> file-read message overwrites previous
-- o -> file-read message
-- c -> completion messages
-- W -> don't show [w] or written when writing
-- T -> truncate file messages at start
-- t -> truncate file messages in middle
-- F -> don't give file info when editing a file
-- x -> do not show [+] or [-] when lines are added/deleted
-- n -> no swap file
-- l -> use internal grep
-- C -> do not give |ins-completion-menu| messages
-- i -> case insensitive search
vim.o.shortmess = 'IOocWTtFxnflCi'

-- automatic reload file on buffer changed outside of vim
vim.o.autoread = true

-- Show those damn hidden characters
-- Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
vim.o.listchars = 'tab: >,nbsp:¬,extends:»,precedes:«,trail:•'

-- Show problematic characters.
vim.o.list = true

-- Stabilize the cursor position when creating/deleting horizontal splits
vim.o.splitkeep = 'topline'

-- sync system clipboard
-- vim.o.clipboard = 'unnamedplus'

-- enable autoformat when saving. it is set for each buffer when lsp is attached
vim.g.autoformat = true
