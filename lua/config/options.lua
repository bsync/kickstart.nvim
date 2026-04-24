-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"
vim.g.autoformat = false
vim.o.winborder = "single"

vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
vim.g.mkdp_auto_close = 0
vim.cmd([[
  function! OpenMarkdownPreview(url)
    if has('wsl')
      call jobstart(['/mnt/c/Program Files/Google/Chrome/Application/chrome.exe', '--new-window', a:url], {'detach': v:true})
    else
      call jobstart(['xdg-open', a:url], {'detach': v:true})
    endif
  endfunction
]])
