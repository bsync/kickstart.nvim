return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    ft = { "markdown" },
    config = function()
      vim.g.mkdp_browser = "chromium"
      vim.g.mkdp_port = "1702"
    end,
  },
}
