return {
  -- Top Level Utilities
  {
    "<leader>.",
    function()
      Snacks.scratch()
    end,
    desc = "Toggle Scratch Buffer",
  },
  {
    "<leader>S",
    function()
      Snacks.scratch.select()
    end,
    desc = "Select Scratch Buffer",
  },
  {
    "<leader>nH",
    function()
      Snacks.notifier.show_history()
    end,
    desc = "Notification History",
  },
  {
    "<leader>bd",
    function()
      Snacks.bufdelete()
    end,
    desc = "Delete Buffer",
  },
  {
    "<leader>cR",
    function()
      Snacks.rename.rename_file()
    end,
    desc = "Rename File",
  },
  {
    "<leader>un",
    function()
      Snacks.notifier.hide()
    end,
    desc = "Dismiss All Notifications",
  },
  {
    "<leader>nd",
    function()
      Snacks.notifier.hide()
    end,
    desc = "Dismiss All Notifications",
  },
  {
    "<leader>GG",
    function()
      Snacks.lazygit()
    end,
    desc = "Lazygit",
  },
  {
    "<leader>gl",
    function()
      Snacks.lazygit.log()
    end,
    desc = "Lazygit Log",
  },
  {
    "<leader>gB",
    function()
      Snacks.gitbrowse()
    end,
    desc = "Git Browse",
  },
  {
    "<leader>gb",
    function()
      Snacks.git.blame_line()
    end,
    desc = "Git Blame Line",
  },
  {
    "<leader>gf",
    function()
      Snacks.lazygit.log_file()
    end,
    desc = "Lazygit Current File Log",
  },

  -- Navigation & View
  {
    "<leader>z",
    function()
      Snacks.zen()
    end,
    desc = "Toggle Zen Mode",
  },
  {
    "<leader>u",
    function()
      Snacks.picker.undo()
    end,
    desc = "Undo History",
  },

  -- Terminal
  {
    "<leader>tt",
    function()
      Snacks.terminal()
    end,
    desc = "Toggle Terminal",
  },
}
