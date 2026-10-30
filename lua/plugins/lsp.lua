-- Python type checking: basedpyright, selected via vim.g.lazyvim_python_lsp for the
-- lang.python extra.
return {
  "neovim/nvim-lspconfig",
  opts = {
    -- LazyVim enables inlay hints by default and re-enables them from a
    -- textDocument/inlayHint response hook (LazyVim plugins/lsp/init.lua), which
    -- runs after LspAttach. An LspAttach autocmd therefore cannot keep them off,
    -- so disable the feature at its source. Toggle with <leader>uh.
    inlay_hints = { enabled = false },
    servers = {
      -- mason has both typescript-language-server (ts_ls) and vtsls installed, and
      -- automatic_enable starts every installed package that nothing excludes. Both then
      -- answer textDocument/references, so `gr` lists each reference twice. vtsls is
      -- the maintained typescript-go fork and supersedes ts_ls.
      ts_ls = { enabled = false },
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
        -- Root at the repository, not at the nearest pyproject.toml. The default markers
        -- stop at any pyproject/setup file, so a nested one -- silverthread's
        -- tests/pyproject.toml, which only holds pytest settings -- became the workspace root
        -- for every file under it, and `from tests.... import ...` could not resolve.
        -- A file with neither marker above it gets no root: it attaches to a shared rootless
        -- basedpyright client, and a pyproject.toml beside it is not read as config.
        root_markers = { "pyrightconfig.json", ".git" },
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
