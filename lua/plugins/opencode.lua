local has_claude = vim.env.NVIM_AI == "claude" and vim.fn.executable("claude") == 1

local snacks_terminal_opts = {
  enabled = true,
  win = {
    position = "float",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    border = "rounded",
    enter = true,
  },
}

local keys = {}

-- Only claim the shared launcher/send/review bindings when Claude Code is NOT available
-- (NVIM_AI != "claude" or `claude` not on $PATH). Otherwise claudecode.nvim owns
-- `<leader>at` / `<leader>aa` / `<leader>ar` (see ai.lua), so exactly one plugin ever maps them.
if not has_claude then
  vim.list_extend(keys, {
    {
      "<leader>aa",
      mode = { "n", "x" },
      function()
        require("opencode").ask("@this: ")
      end,
      desc = "OpenCode: Ask about selection",
    },
    {
      "<leader>at",
      mode = { "n", "t" },
      function()
        require("snacks.terminal").toggle("opencode", snacks_terminal_opts)
      end,
      desc = "OpenCode: Toggle Terminal",
    },
    {
      "<leader>ar",
      mode = "n",
      function()
        require("opencode").select()
      end,
      desc = "OpenCode: Select",
    },
  })
end

return {
  {
    "nickjvandyke/opencode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      vim.g.opencode_opts = {
        server = {
          start = function()
            require("snacks.terminal").open("opencode", snacks_terminal_opts)
          end,
        },
      }
    end,
    keys = keys,
  },
}
