local has_claude = vim.fn.executable("claude") == 1

local keys = {
  { "<leader>a",  nil,                              desc = "AI/Claude Code" },
  { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
  { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
  { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
  { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
  { "<leader>aA", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
  { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
}

-- Shared, tool-preferred bindings. When `claude` is on $PATH, Claude Code owns the
-- launcher (`<leader>at`) and the "send code" binding (`<leader>aa`, formerly `<leader>as`).
-- When it is absent, opencode.nvim claims these same keys instead (see opencode.lua),
-- so exactly one plugin ever maps them.
if has_claude then
  vim.list_extend(keys, {
    { "<leader>at", "<cmd>ClaudeCode<cr>",           desc = "Toggle Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",  desc = "Resume Claude" },
    { "<leader>aa", "<cmd>ClaudeCodeSend<cr>",       desc = "Send to Claude", mode = "v" },
    {
      "<leader>aa",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
  })
end

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      diff_opts = {
        keep_terminal_focus = true, -- snap focus back to the Claude float after a diff opens
        -- open_in_new_tab = true,            -- uncomment to isolate the diff on its own tab
        -- hide_terminal_in_new_tab = true,   -- with open_in_new_tab, skip duplicating the Claude terminal
      },
      terminal = {
        ---@module "snacks"
        ---@type snacks.win.Config|{}
        snacks_win_opts = {
          position = "float",
          border = "rounded",
          width = function() return math.floor(vim.o.columns * 0.9) end,
          height = function() return math.floor(vim.o.lines * 0.9) end,
          keys = {
            claude_hide = {
              "<leader>at",
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
    config = function(_, opts)
      require("claudecode").setup(opts)
      vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "WinEnter" }, {
        callback = function()
          if vim.bo.filetype == "snacks_terminal" or vim.b.snacks_terminal then
            vim.schedule(function() vim.cmd("mode") end)
          end
        end,
      })
    end,
    keys = keys,
  },
}
