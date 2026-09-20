return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  enabled = true,
  config = function()
    local function workspace_name()
      local file = vim.api.nvim_buf_get_name(0)

      if file == "" then
        return "󰉋 No File"
      end

      local file_dir = vim.fs.dirname(file)

      -- Find nearest package.json
      local package_json = vim.fs.find("package.json", {
        upward = true,
        path = file_dir,
      })[1]

      if package_json then
        local package_dir = vim.fs.dirname(package_json)
        return "󰉋 " .. vim.fn.fnamemodify(package_dir, ":t")
      end

      -- Fallback to current folder name
      return "󰉋 " .. vim.fn.fnamemodify(file_dir, ":t")
    end

    local recording_register = vim.fn.reg_recording

    local recording = function()
      local reg = recording_register()
      if reg == "" then
        return ""
      end
      return "󰳥 @" .. reg
    end

    require("lualine").setup({
      options = {
        theme = "auto",
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        icons_enabled = true,
        globalstatus = true,
      },

      sections = {
        lualine_a = {
          { "mode", separator = { left = "", right = "" } },
          recording,
        },

        lualine_b = {
          workspace_name,
          "branch",
          "diff",
          "diagnostics",
        },

        lualine_c = {
          "filename",
          { "filetype", icon_only = true },
        },

        lualine_x = {
          "encoding",
          "fileformat",
          "filetype",
        },

        lualine_y = {
          "progress",
        },

        lualine_z = {
          function()
            local ok, mod = pcall(require, "opencode-status")
            if ok then
              return mod.component()
            end
            return ""
          end,
          { "location", separator = { left = "", right = "" } },
        },
      },
    })
  end,
}
