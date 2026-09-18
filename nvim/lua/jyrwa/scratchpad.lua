-- lua/jyrwa/scratchpad.lua
-- Persistent markdown scratchpad in a centered floating window.
--
-- Buffer file lives at stdpath("data")/scratchpad.md and is auto-saved on
-- every close and on VimLeavePre so it survives full quit/relaunch cycles.
-- render-markdown.nvim is enabled inside the float so pasted markdown renders
-- with headings, code blocks, checkboxes, etc.

local M = {}

local float_win = nil
local float_buf = nil
local origin_win = nil
local origin_buf = nil

local function scratchpad_path()
  return vim.fn.stdpath("data") .. "/scratchpad.md"
end

local function is_valid_win(w)
  return w and vim.api.nvim_win_is_valid(w)
end

local function is_valid_buf(b)
  return b and vim.api.nvim_buf_is_valid(b)
end

-- Ensure the scratchpad file exists (empty with header on first run).
local function ensure_file()
  local p = scratchpad_path()
  if vim.fn.filereadable(p) == 0 then
    local dir = vim.fn.fnamemodify(p, ":h")
    vim.fn.mkdir(dir, "p")
    local fd = io.open(p, "w")
    if fd then
      fd:write("# Scratchpad\n\n")
      fd:close()
    end
  end
  return p
end

-- Save the scratchpad buffer to disk (silent, no notification).
local function save_to_disk()
  if is_valid_buf(float_buf) then
    vim.api.nvim_buf_call(float_buf, function()
      if vim.bo.modified then
        vim.cmd("silent update!")
      end
    end)
  end
end

--- Open the scratchpad in a centered floating window.
--- origin_override lets toggle() pass in the buffer that was in the current
--- window *before* the edit, so closing can restore it correctly.
function M.open(origin_override)
  local path = ensure_file()

  -- Reuse the existing scratchpad buffer if it's still valid.
  if not is_valid_buf(float_buf) then
    float_buf = vim.fn.bufadd(path)
    vim.api.nvim_buf_set_name(float_buf, path)
  end

  -- Ensure the buffer is loaded and attached to the file.
  if not vim.api.nvim_buf_is_loaded(float_buf) then
    vim.fn.bufload(float_buf)
  end

  -- Float already showing the scratchpad — just focus it.
  if is_valid_win(float_win) then
    vim.api.nvim_set_current_win(float_win)
    return
  end

  -- Snapshot the origin window/buffer *before* we touch anything.
  origin_win = vim.api.nvim_get_current_win()
  origin_buf = origin_override or vim.api.nvim_win_get_buf(origin_win)

  -- Open the centred float.
  local width = math.floor(vim.o.columns * 0.75)
  local height = math.floor(vim.o.lines * 0.70)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  float_win = vim.api.nvim_open_win(float_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Scratchpad ",
    title_pos = "center",
  })

  -- Buffer options.
  vim.bo[float_buf].filetype = "markdown"
  vim.bo[float_buf].bufhidden = "hide"
  vim.bo[float_buf].swapfile = false

  -- Window options.
  vim.wo[float_win].wrap = true
  vim.wo[float_win].linebreak = true
  vim.wo[float_win].number = false
  vim.wo[float_win].relativenumber = false

  -- Enable render-markdown in just this buffer so md renders nicely.
  local ok, rm = pcall(require, "render-markdown")
  if ok and rm.enable then
    pcall(rm.enable, float_buf)
  end

  -- Mark as unmodified since we just loaded it.
  vim.bo[float_buf].modified = false

  -- Float-local keymaps (buffer-scoped, don't leak out).
  local function close_and_restore()
    save_to_disk()
    local win = float_win
    local o_win = origin_win
    local o_buf = origin_buf

    if is_valid_win(win) then
      float_win = nil
      float_buf = nil
      vim.api.nvim_win_close(win, true)
    end

    if is_valid_win(o_win) then
      vim.api.nvim_set_current_win(o_win)
      if is_valid_buf(o_buf) then
        vim.api.nvim_win_set_buf(o_win, o_buf)
      end
    end
  end

  vim.keymap.set("n", "<leader>n", close_and_restore, { buffer = float_buf, silent = true, desc = "Close Scratchpad" })
  vim.keymap.set("n", "q", close_and_restore, { buffer = float_buf, silent = true, desc = "Close Scratchpad" })
end

function M.close()
  if not is_valid_win(float_win) then
    return
  end

  save_to_disk()

  local win = float_win
  local o_win = origin_win
  local o_buf = origin_buf

  float_win = nil
  float_buf = nil

  if is_valid_win(win) then
    vim.api.nvim_win_close(win, true)
  end

  if is_valid_win(o_win) then
    vim.api.nvim_set_current_win(o_win)
    if is_valid_buf(o_buf) then
      vim.api.nvim_win_set_buf(o_win, o_buf)
    end
  end
end

function M.toggle()
  if is_valid_win(float_win) then
    M.close()
    return
  end

  -- Capture the pre-open buffer so close can restore it (avoids dup-in-bg).
  local pre_buf = vim.api.nvim_get_current_buf()
  M.open(pre_buf)
end

--- Register keymaps, commands, and the VimLeavePre safety-net autosave.
function M.setup()
  -- Global toggle.
  vim.keymap.set("n", "<leader>n", M.toggle, { silent = true, desc = "Toggle Scratchpad" })

  -- User commands.
  vim.api.nvim_create_user_command("Scratchpad", function() M.toggle() end, { desc = "Toggle scratchpad" })
  vim.api.nvim_create_user_command("ScratchpadClose", function() M.close() end, { desc = "Close scratchpad" })

  -- Persist on quit regardless of whether the float is still visible.
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      save_to_disk()
    end,
  })

  -- Clean up stale window reference if closed externally.
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      if tonumber(args.match) == float_win then
        float_win = nil
        float_buf = nil
      end
    end,
  })
end

return M
