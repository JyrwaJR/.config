return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "cd app && pnpm install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  keys = {
    {
      "<leader>mp",
      "<cmd>MarkdownPreviewToggle<cr>",
      desc = "Markdown Browser Preview",
    },
  },
}
