return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
      sh = { "shfmt" },
    },
    format_on_save = false,
  },
}