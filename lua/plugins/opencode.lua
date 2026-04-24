return {
  {
    "nickjvandyke/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      local snacks_terminal_opts = {
        enabled = true,
        win = {
          position = "float",
          width = math.floor(vim.o.columns * 0.8),
          height = math.floor(vim.o.lines * 0.6),
          border = "rounded",
          enter = true,
        },
      }

      vim.g.opencode_opts = {
        server = {
          start = function()
            require("snacks.terminal").open("opencode --port", snacks_terminal_opts)
          end,
          stop = function()
            require("snacks.terminal").get("opencode --port", snacks_terminal_opts):close()
          end,
          toggle = function()
            require("snacks.terminal").toggle("opencode --port", snacks_terminal_opts)
          end,
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
        mode = { "n", "t" },
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
{
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        ---@module "snacks"
        ---@type snacks.win.Config|{}
        snacks_win_opts = {
          position = "float",
          width = 0.9,
          height = 0.9,
          keys = {
            claude_hide = {
              '<leader>ac',
              function(self)
                self:hide()
              end,
              mode = "t",
              desc = "Hide",
            },
          },
        },
      },
    },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
}
