return {
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release

  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        -- Connect by URL instead of local process discovery.
        -- Discovery relies on `pgrep -f "opencode.*--port"`, which on macOS
        -- can't see servers started in a different terminal session (audit
        -- session scoping), and it rejects servers whose cwd doesn't overlap
        -- Neovim's cwd. A pinned URL bypasses both failure modes.
        --
        -- The server must be started externally with:
        --   opencode --port 4096
        --
        -- For example, from WezTerm / Herdr.
        url = "http://localhost:4096",

        -- Never auto-spawn a new server inside Neovim.
        start = false,
      },

      events = {
        permissions = {
          -- Don't show OpenCode permission prompts in Neovim.
          -- Handle permissions from the external OpenCode CLI instead.
          enabled = false,
        },
      },
    }

    vim.o.autoread = true -- Required for vim.g.opencode_opts.events.reload

    -- Ask about current selection
    vim.keymap.set({ "n", "x" }, "<leader>Oa", function()
      require("opencode").ask("@this: ")
    end, { desc = "Ask OpenCode…" })

    -- OpenCode selector
    vim.keymap.set({ "n", "x" }, "<leader>Os", function()
      require("opencode").select()
    end, { desc = "Select OpenCode…" })

    -- Operator
    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Append range to OpenCode", expr = true })

    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Append line to OpenCode", expr = true })

    -- Scroll OpenCode up
    vim.keymap.set("n", "<leader>Ou", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll OpenCode up" })

    -- Scroll OpenCode down
    vim.keymap.set("n", "<leader>Od", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll OpenCode down" })

    -- Ask raw — no @mention
    vim.keymap.set({ "n", "x" }, "<leader>Oo", function()
      require("opencode").ask("")
    end, { desc = "Open OpenCode prompt" })

    -- Ask about current buffer
    vim.keymap.set({ "n", "x" }, "<leader>Ob", function()
      require("opencode").ask("@buffer: ")
    end, { desc = "Ask about buffer" })

    -- Ask about all buffers
    vim.keymap.set({ "n", "x" }, "<leader>OB", function()
      require("opencode").ask("@buffers: ")
    end, { desc = "Ask about all buffers" })

    -- Fix diagnostics
    vim.keymap.set({ "n", "x" }, "<leader>OD", function()
      require("opencode").ask("Fix @diagnostics")
    end, { desc = "Fix diagnostics" })

    -- Review current selection
    vim.keymap.set({ "n", "x" }, "<leader>Or", function()
      require("opencode").ask("Review @this for correctness and readability")
    end, { desc = "Review @this" })

    -- Explain current selection
    vim.keymap.set({ "n", "x" }, "<leader>Ox", function()
      require("opencode").ask("Explain @this and its context")
    end, { desc = "Explain @this" })

    -- Agent
    vim.keymap.set({ "n", "x" }, "<leader>OA", function()
      require("opencode").command("agent.cycle")
    end, { desc = "Cycle OpenCode agent" })

    -- New session
    vim.keymap.set("n", "<leader>On", function()
      require("opencode").command("session.new")
    end, { desc = "New OpenCode session" })

    -- Interrupt session
    vim.keymap.set("n", "<leader>Oi", function()
      require("opencode").command("session.interrupt")
    end, { desc = "Interrupt OpenCode session" })

    -- Compact session
    vim.keymap.set("n", "<leader>Oc", function()
      require("opencode").command("session.compact")
    end, { desc = "Compact OpenCode session" })

    -- Select session
    vim.keymap.set("n", "<leader>OS", function()
      require("opencode").command("session.select")
    end, { desc = "Select OpenCode session" })

    -- Undo
    vim.keymap.set("n", "<leader>OU", function()
      require("opencode").command("session.undo")
    end, { desc = "Undo OpenCode session" })

    -- Redo
    vim.keymap.set("n", "<leader>OR", function()
      require("opencode").command("session.redo")
    end, { desc = "Redo OpenCode session" })

    -- Clear prompt
    vim.keymap.set({ "n", "x" }, "<leader>Op", function()
      require("opencode").command("prompt.clear")
    end, { desc = "Clear OpenCode prompt" })

    -- Server switching / OpenCode selector
    -- `server.select` was renamed to `server.connect` in opencode.nvim v0.14.0
    -- and is reachable through the select menu.
    vim.keymap.set("n", "<leader>O,", function()
      require("opencode").select()
    end, { desc = "Select OpenCode…" })

    -- Terminal mode navigation
    vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", {
      desc = "Terminal: go to left window",
    })

    vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", {
      desc = "Terminal: go to lower window",
    })

    vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", {
      desc = "Terminal: go to upper window",
    })

    vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", {
      desc = "Terminal: go to right window",
    })

    -- Terminal window resize:
    -- <leader>sm / <leader>se are defined in core/keymaps.lua
  end,
}
