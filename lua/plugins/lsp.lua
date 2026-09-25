-- Python type checking: basedpyright, selected via vim.g.lazyvim_python_lsp for the
-- lang.python extra.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Neovim ships didChangeWatchedFiles.dynamicRegistration = false, so a server is told
      -- the client cannot watch files and never registers watchers. Without this, edits made
      -- outside the editor are invisible to the server: its index keeps the pre-edit copy of
      -- any file no buffer has opened, so find-references silently misses call sites written
      -- by an external tool. Requires inotify-tools -- vim._watch falls back to a directory
      -- poller when inotifywait is absent, which is punishing on a large tree.
      basedpyright = {
        capabilities = {
          workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
        },
        -- basedpyright defaults to "recommended", far stricter than pyright's "standard".
        -- A [tool.basedpyright] / [tool.pyright] section or pyrightconfig.json in a project
        -- overrides this.
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              -- Of the checks "recommended" adds, these two catch real mistakes (an `is None`
              -- test on a non-Optional annotation: wrong annotation or dead code) and ruff
              -- has no equivalent.
              diagnosticSeverityOverrides = {
                reportUnnecessaryComparison = "warning",
                reportUnreachable = "warning",
              },
            },
          },
        },
      },
    },
  },
}
