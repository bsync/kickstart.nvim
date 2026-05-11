-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Fugitive's diff buffers (`fugitive://...`) cause LSP clients (ruff/pyright)
-- to start with a malformed workspace URL of `file://./` and fail. Skip the
-- start entirely for those buffers — detaching after attach is too late, the
-- server has already logged its startup error to stderr by then.
do
  local orig_start = vim.lsp.start
  vim.lsp.start = function(config, opts)
    opts = opts or {}
    local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_name(bufnr):match("^fugitive://") then
      return nil
    end
    return orig_start(config, opts)
  end
end

vim.api.nvim_create_user_command("DiffLast", function()
  local file = vim.fn.expand("%")
  if file == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN)
    return
  end
  local sha = vim.fn
    .system("git log -1 --format=%H -- " .. vim.fn.shellescape(file))
    :gsub("%s+", "")
  if sha == "" then
    vim.notify("No commit touches this file", vim.log.levels.WARN)
    return
  end
  vim.cmd("Gvdiffsplit " .. sha .. "^")
end, { desc = "Diff buffer against the parent of the last commit that touched this file" })

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.keymap.set("n", "gf", function()
      local cfile = vim.fn.expand("<cfile>")
      if cfile == "" then return end

      -- Resolve to a real path (walks up from cwd to find it)
      local path = vim.fn.findfile(cfile, ".;")
      if path == "" then
        path = vim.fn.fnamemodify(cfile, ":p")
      end

      -- Hide the terminal window if there's somewhere else to land
      if #vim.api.nvim_tabpage_list_wins(0) > 1 then
        vim.cmd("hide")
      end

      vim.cmd("edit " .. vim.fn.fnameescape(path))
    end, { buffer = true, silent = true, desc = "gf: open file, close terminal" })
  end,
})
