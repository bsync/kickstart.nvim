return {
  {
    "nickjvandyke/opencode.nvim",
    dependencies = {
      -- LazyVim already includes snacks.nvim, which provides a great terminal UI
      "folke/snacks.nvim",
    },
    config = function()
      -- Uses Snacks.nvim to open OpenCode in a floating terminal
      vim.g.opencode_opts = {
        provider = {
          enabled = "snacks",
          snacks = {
            win = {
              position = "float",
              width = math.floor(vim.o.columns * 0.8), -- 80% screen width
              height = math.floor(vim.o.lines * 0.6), -- 60% screen height
              border = "rounded", -- Rounded border
              enter = true, -- Enter the floating window
            },
          },
        },
      }
    end,
    keys = {
      {
        "<leader>aa",
        mode = { "n", "x" },
        function()
          require("opencode").ask("@this: ", { submit = true })
        end,
        desc = "OpenCode: Ask about selection",
      },
      {
        "<leader>at",
        mode = "n",
        function()
          require("opencode").toggle()
        end,
        desc = "OpenCode: Toggle Terminal",
      },
      {
        "<leader>ar",
        mode = "n",
        function()
          require("opencode").ask("Review the current buffer")
        end,
        desc = "OpenCode: Review Buffer",
      },
    },
  },
}
