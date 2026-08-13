local has_claude = vim.fn.executable("claude") == 1

local keys = {}

-- Only claim the shared launcher/send/review bindings when Claude Code is NOT available.
-- When `claude` is on $PATH, claudecode.nvim owns `<leader>at` / `<leader>aa` / `<leader>ar`
-- (see ai.lua), so exactly one plugin ever maps them.
if not has_claude then
  vim.list_extend(keys, {
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
        require("opencode").select_session()
      end,
      desc = "OpenCode: Resume session",
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
    keys = keys,
  },
}
