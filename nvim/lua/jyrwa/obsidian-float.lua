-- lua/jyrwa/obsidian-float.lua
-- Floating reference pane for Obsidian notes.
--
-- The float window is a presentation layer around the real Obsidian buffer:
-- obsidian.nvim stays the source of truth, so links, frontmatter, templates and
-- the Obsidian command palette keep working inside the float.
--
-- NOTE: the pinned obsidian.nvim build (ae1f76a) does not emit ObsidianNoteEnter,
-- so note entry is detected with a BufEnter autocmd + vault detection instead.

local M = {}

local float_win = nil
local float_buf = nil
local origin_win = nil
local origin_buf = nil
local last_note = nil
local origin_buf_override = nil

local function is_valid_win(w)
  return w and vim.api.nvim_win_is_valid(w)
end

local function is_valid_buf(b)
  return b and vim.api.nvim_buf_is_valid(b)
end

-- True when the buffer is a markdown file inside an Obsidian vault.
-- Detects the vault by walking upward from the buffer dir looking for .obsidian.
local function is_obsidian_note(buf)
  if not is_valid_buf(buf) then
    return false
  end
  if vim.bo[buf].filetype ~= "markdown" then
    return false
  end
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    return false
  end
  local dir = vim.fs.dirname(file)
  local vault = vim.fs.find(".obsidian", { path = dir, upward = true, type = "directory" })
  return #vault > 0
end

local function save_current()
  if is_valid_buf(float_buf) then
    vim.api.nvim_buf_call(float_buf, function()
      if vim.bo.modified then
        vim.cmd("silent update")
      end
    end)
  end
end

-- Open the given buffer (default: current) in a centered floating window.
-- origin_override: buffer to restore in the origin window (used when toggle()
-- reopens last_note into the current window first).
function M.open(buf, origin_override)
  buf = buf or vim.api.nvim_get_current_buf()

  if not is_obsidian_note(buf) then
    vim.notify("Current buffer is not an Obsidian note", vim.log.levels.WARN)
    return
  end

  -- Already floating: just focus the float.
  if is_valid_win(float_win) then
    vim.api.nvim_set_current_win(float_win)
    return
  end

  origin_win = vim.api.nvim_get_current_win()
  origin_buf = origin_override or vim.api.nvim_win_get_buf(origin_win)
  origin_buf_override = nil

  float_buf = buf
  last_note = vim.api.nvim_buf_get_name(buf)

  local width = math.floor(vim.o.columns * 0.75)
  local height = math.floor(vim.o.lines * 0.70)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  float_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Obsidian ",
    title_pos = "center",
    footer = " <leader>n close  |  <leader>ns switch  |  <leader>nn new ",
    footer_pos = "center",
  })

  -- Hide the duplicated note in the origin window: restore whatever was there.
  if is_valid_win(origin_win) and origin_win ~= float_win and is_valid_buf(origin_buf) then
    vim.api.nvim_win_set_buf(origin_win, origin_buf)
  end

  vim.wo[float_win].wrap = true
  vim.wo[float_win].linebreak = true
  vim.wo[float_win].number = false
  vim.wo[float_win].relativenumber = false

  vim.bo[float_buf].bufhidden = "hide"

  -- Float-local mappings (buffer-scoped, do not leak out).
  vim.keymap.set("n", "<leader>n", function()
    M.close()
  end, { buffer = float_buf, silent = true, desc = "Close Obsidian float" })

  vim.keymap.set("n", "<leader>ns", function()
    vim.cmd("ObsidianQuickSwitch")
  end, { buffer = float_buf, silent = true, desc = "Switch Obsidian note" })

  vim.keymap.set("n", "<leader>nn", function()
    vim.cmd("ObsidianNew")
  end, { buffer = float_buf, silent = true, desc = "New Obsidian note" })

  vim.keymap.set("n", "q", function()
    M.close()
  end, { buffer = float_buf, silent = true, desc = "Close Obsidian float" })
end

function M.close()
  if not is_valid_win(float_win) then
    return
  end

  save_current()

  local win = float_win
  local original_win = origin_win
  local original_buf = origin_buf

  float_win = nil
  float_buf = nil

  if is_valid_win(win) then
    vim.api.nvim_win_close(win, true)
  end

  -- Restore the window from which the note was opened.
  if is_valid_win(original_win) then
    vim.api.nvim_set_current_win(original_win)
    if is_valid_buf(original_buf) then
      vim.api.nvim_win_set_buf(original_win, original_buf)
    end
  end
end

function M.toggle()
  if is_valid_win(float_win) then
    M.close()
    return
  end

  local buf = vim.api.nvim_get_current_buf()

  -- If we are already inside an Obsidian note, float that exact file.
  if is_obsidian_note(buf) then
    M.open(buf)
    return
  end

  -- Otherwise reopen the last Obsidian note. Remember what this window showed
  -- before the edit so the duplicate can be hidden once the float opens.
  if last_note and vim.fn.filereadable(last_note) == 1 then
    origin_buf_override = vim.api.nvim_get_current_buf()
    vim.cmd("edit " .. vim.fn.fnameescape(last_note))
    return
  end

  -- Fall back to Obsidian quick switch.
  vim.cmd("ObsidianQuickSwitch")
end

-- Detect note entry without ObsidianNoteEnter: on BufEnter, if a vault markdown
-- buffer became active in the float window, just track it; otherwise (no float
-- open) float the note.
function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(args)
      local buf = args.buf
      if not is_obsidian_note(buf) then
        return
      end

      -- Entering a note inside the existing float: track it, no new float.
      if is_valid_win(float_win) and vim.api.nvim_get_current_win() == float_win then
        float_buf = buf
        last_note = vim.api.nvim_buf_get_name(buf)
        return
      end

      -- No float open and a note was entered anywhere else: float it.
      if not is_valid_win(float_win) then
        vim.schedule(function()
          if is_valid_buf(buf) and not is_valid_win(float_win) then
            M.open(buf, origin_buf_override)
          end
        end)
      end
    end,
  })

  -- Clean up when the float is closed unexpectedly.
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      if tonumber(args.match) == float_win then
        float_win = nil
        float_buf = nil
      end
    end,
  })

  vim.api.nvim_create_user_command("ObsidianFloat", function()
    M.toggle()
  end, {})

  vim.api.nvim_create_user_command("ObsidianFloatClose", function()
    M.close()
  end, {})

  vim.keymap.set("n", "<leader>n", M.toggle, {
    silent = true,
    desc = "Toggle Obsidian float",
  })

  vim.keymap.set("n", "<leader>ns", function()
    vim.cmd("ObsidianQuickSwitch")
  end, {
    silent = true,
    desc = "Switch Obsidian note",
  })

  vim.keymap.set("n", "<leader>nn", function()
    vim.cmd("ObsidianNew")
  end, {
    silent = true,
    desc = "New Obsidian note",
  })
end

return M