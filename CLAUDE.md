# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration built on top of [LazyVim](https://github.com/LazyVim/LazyVim). It is loaded from `~/.config/nvim` when `nvim` starts — there is no build step. Changes take effect on the next `nvim` launch (or after `:Lazy reload`).

## Architecture

Boot order is dictated by LazyVim's conventions, not by file names:

1. `init.lua` calls `require("config.lazy")`.
2. `lua/config/lazy.lua` bootstraps `lazy.nvim`, then loads two specs in order:
   - `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }` — the full LazyVim plugin set.
   - `{ import = "plugins" }` — every `*.lua` file under `lua/plugins/`, which **overrides or extends** the LazyVim defaults using lazy.nvim's spec-merging rules.
3. LazyVim auto-loads `lua/config/options.lua` before plugins, and `lua/config/keymaps.lua` + `lua/config/autocmds.lua` on the `VeryLazy` event. Do not `require` these manually.
4. `after/ftplugin/<ft>.lua` runs per-buffer for that filetype (e.g. `python.lua` adds a breakpoint mapping only in Python buffers).

When adding a plugin or changing behavior, decide which layer you're touching:
- New/overridden plugin spec → new file in `lua/plugins/` returning a table. Files there are auto-imported; there is no central registry to update.
- Global option / leader / vim.g variable → `lua/config/options.lua`.
- Global keymap → `lua/config/keymaps.lua`.
- Filetype-specific behavior → `after/ftplugin/<ft>.lua`.

`lua/plugins/example.lua` is an inert reference file (`if true then return {} end`) — leave it as documentation of common spec patterns; do not add live config there.

## Conventions that differ from vanilla LazyVim

- **Leader key is `;`** (`vim.g.mapleader = ";"`, also as localleader). Any new mapping should assume this. The default `<leader>,` binding is deleted in `keymaps.lua`.
- **`vim.g.autoformat = false`** — LazyVim's format-on-save is globally off. `conform.nvim` is configured with `format_on_save = false` to match. Formatting is manual (`<leader>cf` / `:Format`). Preserve this unless the user asks otherwise.
- **Formatters** (conform.nvim in `lua/plugins/conform.lua`): lua → stylua, python → black, sh → shfmt. Lua style is enforced by `stylua.toml` (2-space indent, 120-column width).
- **Python type checker is `pyrefly`**, not pyright (`lua/plugins/lsp.lua`). There is no LSP server list in this config other than that file — servers come from whatever mason has installed, which `mason-lspconfig`'s `automatic_enable` turns on. So disabling a server means an explicit `<server> = { enabled = false }` entry (as pyright has), not just removing a spec. `ruff` still runs alongside for linting.
- **WSL markdown preview**: `options.lua` defines `OpenMarkdownPreview` which shells out to `/mnt/c/.../chrome.exe` on WSL and `xdg-open` elsewhere; `markdown.lua` sets port 1702. This is WSL-aware by design.
- **Explorer is `mini.files`**, not neo-tree or snacks.explorer. `<leader>e` opens it at cwd; `-` opens it at the current buffer's parent. `mini.lua` sets `use_as_default_explorer = true` and overrides `snacks.nvim` with `explorer.replace_netrw = false` so that editing a directory (e.g. `:e .`) hands off to mini.files instead of snacks. An autocmd closes the window on `BufWipeout` to avoid a stuck buffer.

## The `<leader>g` (git) namespace

Reorganized so each git plugin owns one sub-prefix. There is **no `<leader>gh` "hunks" group** — `git.lua` strips it from which-key's spec and replaces LazyVim's whole gitsigns `on_attach` (chaining it would leave the old buffer-local `<leader>gh*` maps in place, and buffer-local maps can't be cleanly deleted afterwards). So:

- **`<leader>gs*` = gitsigns.** Buffer-local actions in `git.lua`'s `on_attach` (`gss`/`gsr` stage/reset hunk, `gsS`/`gsR` buffer, `gsu` undo stage, `gsp`/`gsP` inline/float preview, `gsb`/`gsB` blame, `gsd`/`gsD` diff this); global ones in `keymaps.lua` (`gsq` quickfix all hunks, `gsi`/`gsI` point the gutter base at the integration merge-base / back at the index). Adding a gitsigns binding means picking a sub-key here, not a new top-level `<leader>g` key.
- **`<leader>gd*` = diffview** (which-key group "diff view"): `gdw`/`gdI` vs integration with/without uncommitted work, `gdi` working tree, `gdD` close. Nothing diffview sits on a top-level `<leader>g` key.
- The snacks pickers on `<leader>gd`, `<leader>gD`, and `<leader>gs` are disabled in `git.lua`; git status lives on `<leader>fG` instead. `<leader>gD` stays disabled rather than reverting to snacks' "Git Diff (origin)" — the point of the sub-prefixes is to keep the top-level namespace to one key per plugin. LazyVim's remaining single-key `<leader>g` bindings (`gg` lazygit, `gb` blame line, `gf` file history, `gl`/`gL` log, `gB` browse, `gi`/`gI`/`gp`/`gP` GitHub issues & PRs) are untouched.
- Hunk motions: `]h`/`[h` and `]c`/`[c` both step hunks (falling back to vim's diff motions in a diff window), `]H`/`[H` jump to first/last, `]C`/`[C` step with a floating preview. `git.lua` unbinds `]c`/`[c` from treesitter-textobjects class navigation to make that possible.

## AI plugin stack (heads-up for conflicts)

`lua/plugins/opencode.lua` registers **two** AI integrations in the same file:
- `nickjvandyke/opencode.nvim` — runs `opencode --port` inside a `snacks.terminal` float.
- `coder/claudecode.nvim` — Claude Code bridge.

They share the `<leader>a*` namespace. The launcher (`<leader>at`), "send code" (`<leader>aa`), and review/resume (`<leader>ar`) bindings are **claimed conditionally at startup** via `vim.fn.executable("claude")`: when `claude` is on `$PATH`, `ai.lua` maps them to Claude Code (`ClaudeCode` / `ClaudeCodeSend`+`ClaudeCodeTreeAdd` / `ClaudeCode --resume`); otherwise `opencode.lua` maps them to opencode (`toggle()` / `ask("@this: ")` / `select_session()`). Each file computes `local has_claude = ...` at the top and gates those keys behind it, so exactly one plugin ever owns them — do not add `<leader>at`/`<leader>aa`/`<leader>ar` unconditionally in either file. Claude's diff-accept lives on `<leader>aA` (accept) / `<leader>ad` (deny). When editing bindings here, check both blocks.

`lua/plugins/copilot.lua` wires `Exafunction/windsurf.vim` (Codeium) with insert-mode accept/cycle mappings (`<C-g>`, `<C-;>`, `<C-,>`, `<C-x>`).

## Common commands inside Neovim

- `:Lazy` — plugin manager UI (sync / update / clean).
- `:Lazy sync` — install + update + clean in one go after editing a plugin spec.
- `:Mason` — manage external tools (LSPs, formatters, linters).
- `:checkhealth` — diagnose plugin/runtime issues.
- `:Format` (conform.nvim) — format the current buffer on demand.

## Committed vs. ignored

`lazy-lock.json` **is** committed — it pins plugin commits for reproducible installs, so include it when a plugin change moves the lockfile. `.gitignore` excludes scratch files (`tt.*`, `foo.*`, `*.log`, `.tests`, `.repro`, `data`, `doc/tags`).

Because the lockfile is regenerated on every `:Lazy sync`, it conflicts on nearly every merge/rebase. `.gitattributes` marks it `merge=ours` so git auto-resolves it to the current branch's version (on a rebase, that's the base) instead of stopping. The resolution is never authoritative — whichever side wins, `:Lazy sync` reconciles it against the specs on next launch, and `git checkout <sha> -- lazy-lock.json` + `:Lazy restore` still rolls back to any past pinned set. The driver itself lives in local config, not the repo, so **a fresh clone must run `git config merge.ours.driver true`** — without it git silently falls back to a normal text merge and conflicts as before (no error, so it fails quietly). One side effect: a commit that touches *only* the lockfile (like `f6e7311 plugin lock updates`) resolves to an empty patch during a rebase and gets dropped.
