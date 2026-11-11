local has_claude = vim.env.NVIM_AI == "claude" and vim.fn.executable("claude") == 1

-- OpenCode v2 runs a background service that the TUI client attaches to.
-- `opencode --port` was a v1 flag; in v2 it exits non-zero and prints usage.
local opencode_cmd = "opencode"

-- Last resolved project directory, so a scratch buffer keeps using the
-- project's TUI instead of spawning a second one.
local last_root

---Directory the OpenCode TUI runs in.
---Snacks identifies a terminal by cmd + cwd + count, so this has to stay
---stable: otherwise every buffer switch opens another TUI.
---@return string
local function project_dir()
  local root = LazyVim.root.get()
  if root and vim.api.nvim_buf_get_name(0) ~= "" then
    last_root = root
    return root
  end
  return last_root or root or vim.fn.getcwd()
end

---@return snacks.terminal.Opts
local function terminal_opts()
  return {
    enabled = true,
    -- Pin both identity fields, or a count prefix or a different cwd
    -- creates a second terminal for the same command.
    count = 1,
    cwd = project_dir(),
    win = {
      position = "float",
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
      border = "rounded",
      enter = true,
    },
  }
end

---Focus the OpenCode TUI and run its session picker there.
---OpenCode v2 has no `/resume`; `/sessions` reopens an existing session in the
---same TUI (Ctrl+X then L does the same, Ctrl+O lists sessions and projects).
local function switch_session()
  local term, created = require("snacks.terminal").get(opencode_cmd, terminal_opts())
  if not term then
    return
  end
  term:show():focus()

  local function send()
    local job = vim.b[term.buf] and vim.b[term.buf].terminal_job_id
    if not job then
      vim.notify("OpenCode terminal is not running", vim.log.levels.ERROR, { title = "opencode" })
      return
    end
    -- Clear the prompt line so the slash command is the only input.
    vim.api.nvim_chan_send(job, "\15")
    vim.api.nvim_chan_send(job, "/sessions")
    -- Give the TUI a moment to render its command list before submitting.
    vim.defer_fn(function()
      if vim.b[term.buf] and vim.b[term.buf].terminal_job_id == job then
        vim.api.nvim_chan_send(job, "\r")
      end
    end, 200)
  end

  if created then
    -- A fresh TUI needs a moment to boot before it accepts input.
    vim.defer_fn(send, 1500)
  else
    send()
  end
end

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
        -- v2 dropped the `submit` option: the input opens pre-filled, press Enter to send.
        require("opencode").ask("@this: ")
      end,
      desc = "OpenCode: Ask about selection",
    },
    {
      "<leader>at",
      -- Terminal mode too, so the float can be toggled from inside the TUI itself.
      -- `floaterm.lua` maps `<leader>tt`/`<leader>tn`/`<leader>tp` in terminal mode for
      -- the same reason.
      mode = { "n", "t" },
      function()
        -- `require("opencode").toggle()` was removed in v2; drive snacks directly.
        require("snacks.terminal").toggle(opencode_cmd, terminal_opts())
      end,
      desc = "OpenCode: Toggle Terminal",
    },
    {
      "<leader>ar",
      mode = "n",
      switch_session,
      desc = "OpenCode: Switch session",
    },
    {
      -- v2's `select()` is the prompt/command palette (the configured prompts plus the
      -- server's registered commands) — it is *not* a session picker, so it does not
      -- replace `<leader>ar`. It talks to the server directly, no TUI involved.
      "<leader>aS",
      mode = { "n", "x" },
      function()
        require("opencode").select()
      end,
      desc = "OpenCode: Select prompt or command",
    },
  })
end

return {
  {
    "nickjvandyke/opencode.nvim",
    -- `main` supports OpenCode v2; the released tags are still v1.
    version = "main",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
      vim.g.opencode_opts = {
        server = {
          -- v2 discovers the background service on its own (service.json in the state dir).
          -- This is the fallback used when no service is registered yet.
          start = function()
            require("snacks.terminal").open(opencode_cmd, terminal_opts())
          end,
        },
      }
    end,
    keys = keys,
  },
}
