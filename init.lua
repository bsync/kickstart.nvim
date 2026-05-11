-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

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
