vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = false
opt.number = false
-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.wrap = false -- wrap lines
-- search settings
opt.title = true -- set the title of window to the value of the titlestring
opt.hlsearch = true -- highlight all matches
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
opt.cursorline = false -- highlight the current line
opt.inccommand = "split"
opt.breakindent = true -- enable break indent
-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = { "indent", "eol", "start" } -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- spell check
opt.spelllang = "en_us"
opt.spell = true
-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swap file
opt.swapfile = false -- turn off swap file

-- save undo history (persistent across restarts)
opt.undofile = true
opt.undolevels = 10000
opt.undoreload = 10000
-- Ensure the undo directory exists so persistence actually works
-- Neovim defaults to stdpath("state")/undo on macOS
vim.fn.mkdir(vim.fn.stdpath("state") .. "/undo", "p")

-- Get 8 line below and above the cursor
opt.scrolloff = 10 -- minimal number of screen lines to keep above and below the cursor

-- Additional settings
opt.conceallevel = 0 -- so that `` is visible in markdown files

opt.laststatus = 3 -- global statusline (lualine), shown by default

-- Increase terminal key sequence timeout so <leader>sm/se work in terminal mode
-- Default is 50ms which is too fast for leader sequences
-- 300ms gives enough time for leader sequences without making typing feel sluggish
vim.o.ttimeoutlen = 300
