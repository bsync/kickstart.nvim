return {
  {
    "voldikss/vim-floaterm",
    config = function ()
      vim.g.floaterm_width = .8
      vim.g.floaterm_height = .8
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
          vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = true })
        end,
      })
    end,
    keys = {
      { "<leader>tf", "<cmd>FloatermNew<cr>", desc = "New floating terminal" },
      { "<leader>tt", "<cmd>FloatermToggle<cr>", desc = "Toggle floating terminal" },
      { "<leader>tn", "<cmd>FloatermNext<cr>", desc = "Next floating terminal" },
      { "<leader>tp", "<cmd>FloatermPrev<cr>", desc = "Prev floating terminal" },
      { "<leader>tl", function() require("floaterm").pick() end, desc = "Pick floating terminal" },
    },
  },
}
