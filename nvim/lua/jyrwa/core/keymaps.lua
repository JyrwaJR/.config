vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
-- Delete to black hole register (don't copy deleted text)
keymap.set("n", "dd", '"_dd', { noremap = true, desc = "Delete line without copying" })
keymap.set("n", "d", '"_d', { noremap = true, desc = "Delete without copying" })
keymap.set("v", "d", '"_d', { noremap = true, desc = "Delete without copying" })

-- Paste in visual mode without yanking replaced text
keymap.set("v", "p", '"_dP', { noremap = true, desc = "Paste without copying replaced text" })
keymap.set("x", "p", '"_dP', { noremap = true, desc = "Paste without copying replaced text" })

-- Optional: Normal mode paste works as default
keymap.set("n", "p", "p", { noremap = true, desc = "Paste" })
-- write file
keymap.set("n", "<leader>w", "<CR>:wa<CR>", { noremap = true, silent = false, desc = "Save file" })
--
-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
-- Noice notifications
keymap.set("n", "<leader>cn", "<cmd>NoiceDismiss<CR>", { desc = "Close all notifications" })

-- Telescope Keymaps
keymap.set(
  "n",
  "<leader>fw",
  "<cmd>Telescope current_buffer_fuzzy_find<cr>",
  { desc = "Find word in the current file" }
)

keymap.set("n", "<leader>fH", "<cmd>Telescope search_history<cr>", { desc = "Find search history" })
keymap.set("n", "<leader>fhc", "<cmd>Telescope command_history<cr>", { desc = "Find commands history" })
keymap.set("n", "<leader>fa", "<cmd>Telescope autocommands<cr>", { desc = "Find auto commands" })
keymap.set("n", "<leader>fC", "<cmd>Telescope commands<cr>", { desc = "Find commands" })
keymap.set("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Fuzzy find Mark in cwd" })
keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Fuzzy find keymap in cwd" })
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
keymap.set("n", "<leader>fh", "<cmd>Telescope colorscheme enable_preview=true<cr>", { desc = "Fuzzy find themes" })
keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
keymap.set("n", "<leader>fn", "<cmd>Telescope noice<cr>", { desc = "Fuzzy find noice" })
keymap.set("n", "<leader>fu", "<cmd>Telescope undo<cr>", { desc = "Fuzzy find undo" })
keymap.set("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Fuzzy find resume" })
keymap.set("n", "<leader>fj", "<cmd>Telescope jumplist<cr>", { desc = "Fuzzy find jumplist" })

-- Git
keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Fuzzy find git diff" })
keymap.set("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Find Git Files" })
keymap.set("n", "<leader>gC", "<cmd>Telescope git_bcommits<cr>", { desc = "Fuzzy find commits for current file" })
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Fuzzy find git branches" })
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Fuzzy find git status" })
keymap.set("n", "<leader>gS", "<cmd>Telescope git_stash<cr>", { desc = "Fuzzy find git stash" })

-- Snacks Explorer & Utilities
keymap.set("n", "<leader>ee", function()
  Snacks.picker.explorer()
end, { desc = "Toggle Snacks explorer" })
keymap.set("n", "<leader>ef", function()
  Snacks.picker.explorer()
end, { desc = "Snacks explorer (strict follow)" })

-- Trouble
keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle Trouble" })
keymap.set("n", "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble workspace diagnostics" })
keymap.set(
  "n",
  "<leader>xd",
  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  { desc = "Toggle Trouble document diagnostics" }
)
keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", { desc = "Toggle Trouble quickfix list" })
keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Toggle Trouble location list" })
keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Toggle Todos in Trouble" })

-- Vim Maximizer
keymap.set("n", "<leader>sm", function()
  if vim.t.maximized then
    vim.cmd("wincmd =")
    vim.t.maximized = false
  else
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
    vim.t.maximized = true
  end
end, { desc = "Toggle Split Maximizer" })
-- Terminal mode: same toggle, uses vim.cmd which works from any mode
keymap.set("t", "<leader>sm", function()
  if vim.t.maximized then
    vim.cmd("wincmd =")
    vim.t.maximized = false
  else
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
    vim.t.maximized = true
  end
end, { desc = "Terminal: toggle split maximizer" })

-- Terminal mode: equalize splits (escape to normal, then <C-w>=)
keymap.set("t", "<leader>se", "<C-\\><C-n><C-w>=", { desc = "Terminal: make splits equal size" })

-- DADBOD
keymap.set("n", "<leader>dd", ":DBUI<CR>", { desc = "Open DB UI" })
keymap.set("n", "<leader>dT", ":DBUIToggle<CR>", { desc = "Toggle DB UI" })
keymap.set("n", "<leader>dF", ":DBUIFindBuffer<CR>", { desc = "Find buffer in DB UI" })

-- Run query under cursor or visual selection
keymap.set("n", "<leader>dr", ":.DB<CR>", { desc = "Run current line as query" })
keymap.set("v", "<leader>dr", ":'<,'>DB<CR>", { desc = "Run visual selection as query" })

-- Save current query buffer
keymap.set("n", "<leader>ds", function()
  local name = vim.fn.input("Save query as: ")
  if name and name ~= "" then
    vim.cmd("DBUI save " .. name)
  end
end, { desc = "Save query with name" })

-- Spectre (Search & Replace)
keymap.set("n", "<leader>Sr", '<cmd>lua require("spectre").toggle()<CR>', {
  desc = "Toggle Spectre",
})
keymap.set("n", "<leader>Sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "Search current word",
})
keymap.set("n", "<leader>Sf", '<cmd>lua require("spectre").open_file_search()<CR>', {
  desc = "Search on current file",
})

keymap.set("n", "<leader>ul", function()
  if vim.o.laststatus == 0 then
    vim.o.laststatus = 3
  else
    vim.o.laststatus = 0
  end
end, { desc = "Toggle Lualine" }) -- lualine
