-- Python type checking: pyrefly instead of pyright.
-- pyright is still present in mason, so it has to be explicitly disabled or
-- mason-lspconfig's automatic_enable would start it alongside pyrefly.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = { enabled = false },
      -- Neovim ships didChangeWatchedFiles.dynamicRegistration = false, so a server is told
      -- the client cannot watch files and never registers watchers. Without this, edits made
      -- outside the editor are invisible to pyrefly: its index keeps the pre-edit copy of any
      -- file no buffer has opened, so find-references silently misses call sites written by
      -- an external tool. Requires inotify-tools -- vim._watch falls back to a directory
      -- poller when inotifywait is absent, which is punishing on a large tree.
      pyrefly = {
        capabilities = {
          workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
        },
      },
    },
  },
}
