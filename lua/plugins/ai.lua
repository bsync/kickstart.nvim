local has_claude = vim.env.NVIM_AI == "claude" and vim.fn.executable("claude") == 1

if not has_claude then
  return {}
end
local keys = {
  { "<leader>a",  nil,                              desc = "AI/Claude Code" },
  { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
  { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
  { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
  { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
  { "<leader>aA", "<cmd>ClaudeCodeDiffAccept<cr>",  desc = "Accept diff" },
  { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",    desc = "Deny diff" },
}

-- Shared, tool-preferred bindings. Claude Code owns the launcher (`<leader>at`) and
-- the "send code" binding (`<leader>aa`, formerly `<leader>as`) when NVIM_AI is
-- "claude" and `claude` is on $PATH. Otherwise opencode.nvim claims these same
-- keys instead (see opencode.lua), so exactly one plugin ever maps them.
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
      focus_after_send = true, -- every send/add (<leader>aa, <leader>ab, tree add) jumps into the Claude float
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
      -- claudecode.nvim hides its Snacks float with nvim_win_set_config({hide=true}) instead of
      -- closing it, and a float belongs to one tabpage. Left alone, the Claude float stays in the
      -- tab it was first opened in, so <leader>aa / <leader>at from another tab (e.g. Diffview)
      -- show it off-screen. On entering a tab, close any floating window showing the Claude
      -- terminal buffer in another tab (the buffer and its job survive, as with Snacks' own hide)
      -- so the next show recreates the float here. Only floats: a split of the terminal (e.g.
      -- claudecode's open_in_new_tab diff layout) belongs to the tab it was opened in and may be
      -- that tab's last window.
      local group = vim.api.nvim_create_augroup("user_claudecode", { clear = true })
      vim.api.nvim_create_autocmd("TabEnter", {
        group = group,
        callback = function()
          local bufnr = require("claudecode.terminal").get_active_terminal_bufnr()
          if not bufnr then
            return
          end
          -- Snacks' WinClosed handler closes the backdrop along with the float.
          local tab = vim.api.nvim_get_current_tabpage()
          for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
            if vim.api.nvim_win_get_config(win).relative ~= "" and vim.api.nvim_win_get_tabpage(win) ~= tab then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
        end,
      })
      vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "WinEnter" }, {
        group = group,
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
