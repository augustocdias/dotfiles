-- enables experimental lua loader
vim.loader.enable()

-- map leader to space
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

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
vim.g.editorconfig = true
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
vim.o.numberwidth = 1

-- folding
vim.o.foldenable = true                            -- Enable folding.
vim.o.foldcolumn = '1'                             -- Show folding signs.
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- Use treesitter for folding.
vim.o.foldlevel = 999                              -- Open all folds.
vim.o.foldmethod = 'expr'                          -- Use expr to determine fold level.
vim.o.foldopen = 'insert,mark,search,tag'          -- Which commands open folds if the cursor moves into a closed fold.
vim.o.foldtext = 'v:lua.custom_fold_text()'        -- What to display on fold
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
-- t -> wrap text using textwidth
-- c -> wrap comments using textwidth
-- r -> continue comments when pressing ENTER in I mode
-- q -> enable formatting of comments with gq
-- n -> detect lists for formatting
-- b -> auto-wrap in insert mode, and do not wrap old long lines
vim.o.formatoptions = 'tcrqnb'

-- Proper search
vim.o.incsearch = true
vim.o.inccommand = 'split'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.gdefault = true

-- Abbreviations
for _, pair in ipairs({
    { 'W!',    'w!' },
    { 'Q!',    'q!' },
    { 'Qall!', 'qall!' },
    { 'Wq',    'wq' },
    { 'Wa',    'wa' },
    { 'wQ',    'wq' },
    { 'WQ',    'wq' },
    { 'W',     'w' },
    { 'Q',     'q' },
    { 'Qall',  'qall' },
}) do
    vim.cmd.cnoreabbrev(pair[1] .. ' ' .. pair[2])
end

-- Make diffing better: https://vimways.org/2018/the-power-of-diff/
vim.o.diffopt = 'internal,filler,closeoff,indent-heuristic,inline:char,iwhite,algorithm:patience,linematch:50'

-- don't create swap files because it is very annoying
vim.o.swapfile = false

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
vim.o.clipboard = 'unnamedplus'

-- disable legacy perl provider
vim.g.loaded_perl_provider = false
