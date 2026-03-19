return {
  {
    "mini-files/mini.files",
    event = "VeryLazy",
    keys = {
      { "-", function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end, desc = "Open parent directory" },
    },
    config = function()
      require("mini.files").setup({
        windows = {
          preview = false,
          width_focus = 50,
          width_preview = 50,
        },
        options = {
          use_as_default_explorer = true,
        },
      })

      local miniFilesClose = require("mini.files").close
      vim.api.nvim_create_autocmd("BufWipeout", {
        pattern = "*",
        callback = function(args)
          if vim.bo[args.buf].filetype == "minifiles" then
            miniFilesClose()
          end
        end,
      })
    end,
  },
}
