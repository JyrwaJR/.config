return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian note" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian notes" },
    { "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show Backlinks" },
    { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's Note" },
    { "<leader>ot", "<cmd>ObsidianTomorrow<cr>", desc = "Tomorrow's Note" },
    { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's Note" },
    { "<leader>osw", "<cmd>ObsidianWorkspace<cr>", desc = "Switch Workspace" },
    { "<leader>oi", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
    { "<leader>ol", "<cmd>ObsidianLink<cr>", desc = "Link Text" },
    { "<leader>oln", "<cmd>ObsidianLinkNew<cr>", desc = "Link New Note" },
    { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Rename Note" },
    { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian App" },
    { "<leader>otg", "<cmd>ObsidianTags<cr>", desc = "Search Tags" },
    { "<leader>oll", "<cmd>ObsidianLinks<cr>", desc = "Search Links" },
    { "<leader>odd", "<cmd>ObsidianDailies<cr>", desc = "Browse Daily Notes" },
    { "<leader>oen", ":ObsidianExtractNote<cr>", mode = "v", desc = "Extract Selection to Note" },
    { "<leader>ok", "<cmd>ObsidianCheck<cr>", desc = "Check Vault" },
    { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste Image" },
    { "<leader>opl", "<cmd>ObsidianLink<cr>", mode = "v", desc = "Paste Link on Selection" },
    { "<leader>opb", "<cmd>ObsidianPasteLink<cr>", desc = "Paste as Link" },
    {
      "<leader>ox",
      function()
        local path = vim.api.nvim_buf_get_name(0)
        local confirm = vim.fn.confirm("Delete note: " .. vim.fn.fnamemodify(path, ":t") .. "?", "&Yes\n&No", 2)
        if confirm == 1 then
          vim.cmd("bwipeout")
          vim.fn.delete(path)
          vim.notify("Note deleted")
        end
      end,
      desc = "Delete Note",
    },
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/obsidian-note"),
      },
      {
        name = "work",
        path = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/work-vault"),
      },
    },
    templates = {
      subdir = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Templates"),
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {
        hostname = function()
          return vim.fn.hostname()
        end,
        user = function()
          return os.getenv("USER")
        end,
      },
    },
    -- Daily notes configuration
    daily_notes = {
      folder = "dailies",
      date_format = "%Y-%m-%d",
      alias_format = "%B %-d, %Y",
      template = "daily-template.md",
    },
    new_notes_location = "current_dir",
    wiki_link_func = function(opts)
      if opts.id == nil then
        return string.format("[[%s]]", opts.label)
      elseif opts.label ~= opts.id then
        return string.format("[[%s|%s]]", opts.id, opts.label)
      else
        return string.format("[[%s]]", opts.id)
      end
    end,
    markdown_link_func = function(opts)
      return string.format("[%s](%s)", opts.label, opts.path or opts.url or "")
    end,
    completion = {
      nvim_cmp = false,
      min_chars = 2,
    },
    mappings = {
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
    finder = "telescope.nvim",
    open_notes_in = "current",
    sort_by = "modified",
    sort_reversed = true,
    open_app_foreground = false,
    ui = { enable = false },
  },
}
