-- Python type checking: pyrefly instead of pyright.
-- pyright is still present in mason, so it has to be explicitly disabled or
-- mason-lspconfig's automatic_enable would start it alongside pyrefly.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = { enabled = false },
      pyrefly = {},
    },
  },
}
