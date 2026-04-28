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
- **WSL markdown preview**: `options.lua` defines `OpenMarkdownPreview` which shells out to `/mnt/c/.../chrome.exe` on WSL and `xdg-open` elsewhere; `markdown.lua` sets port 1702. This is WSL-aware by design.
- **Explorer is `mini.files`**, not neo-tree or snacks.explorer. `<leader>e` opens it at cwd; `-` opens it at the current buffer's parent. `mini.lua` sets `use_as_default_explorer = true` and overrides `snacks.nvim` with `explorer.replace_netrw = false` so that editing a directory (e.g. `:e .`) hands off to mini.files instead of snacks. An autocmd closes the window on `BufWipeout` to avoid a stuck buffer.

## AI plugin stack (heads-up for conflicts)

`lua/plugins/opencode.lua` registers **two** AI integrations in the same file:
- `nickjvandyke/opencode.nvim` — runs `opencode --port` inside a `snacks.terminal` float.
- `coder/claudecode.nvim` — Claude Code bridge.

They share the `<leader>a*` namespace and **collide on `<leader>aa` and `<leader>ar`** (opencode's "ask about selection" / "review buffer" vs. claudecode's "accept diff" / "resume"). Whichever plugin's `keys` spec is evaluated later wins. When editing bindings here, check both blocks.

`lua/plugins/copilot.lua` wires `Exafunction/windsurf.vim` (Codeium) with insert-mode accept/cycle mappings (`<C-g>`, `<C-;>`, `<C-,>`, `<C-x>`).

## Common commands inside Neovim

- `:Lazy` — plugin manager UI (sync / update / clean).
- `:Lazy sync` — install + update + clean in one go after editing a plugin spec.
- `:Mason` — manage external tools (LSPs, formatters, linters).
- `:checkhealth` — diagnose plugin/runtime issues.
- `:Format` (conform.nvim) — format the current buffer on demand.

## Committed vs. ignored

`lazy-lock.json` **is** committed — it pins plugin commits for reproducible installs, so include it when a plugin change moves the lockfile. `.gitignore` excludes scratch files (`tt.*`, `foo.*`, `*.log`, `.tests`, `.repro`, `data`, `doc/tags`).
