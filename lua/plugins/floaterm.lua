-- Rotate through every floating terminal, not just floaterms: the ring is the floaterms (in
-- FloatermNext order) followed by the floating Snacks terminals, which is where the Claude Code
-- (claudecode.nvim) and opencode floats live. :FloatermNext/:FloatermPrev only know about
-- floaterm's own buffer list, so they can't step from a floaterm back to the Claude float.

-- Build the ring as a list of { buf, show, hide } entries.
local function terminal_ring()
  local ring = {}
  for _, buf in ipairs(vim.fn["floaterm#buflist#gather"]()) do
    table.insert(ring, {
      buf = buf,
      show = function()
        -- Advance floaterm's own "current" pointer to `buf` so a later :FloatermToggle reopens
        -- the floaterm shown here rather than the one :FloatermNext last landed on.
        for _ = 1, #vim.fn["floaterm#buflist#gather"]() do
          if vim.fn["floaterm#buflist#next"]() == buf then
            break
          end
        end
        vim.fn["floaterm#terminal#open_existing"](buf)
      end,
      hide = function()
        vim.fn["floaterm#hide"](0, buf, "")
      end,
    })
  end

  local ok, snacks_terminal = pcall(require, "snacks.terminal")
  if ok then
    local floats = vim.tbl_filter(function(t)
      return t.opts.position == "float"
    end, snacks_terminal.list())
    -- Snacks keeps terminals in a hash keyed by id; sort by buffer so the order is stable.
    table.sort(floats, function(a, b)
      return a.buf < b.buf
    end)
    for _, t in ipairs(floats) do
      table.insert(ring, {
        buf = t.buf,
        show = function()
          t:show()
          t:focus()
        end,
        hide = function()
          t:hide()
        end,
      })
    end
  end
  return ring
end

-- Hide the ring entry the cursor is in and show the one `step` (+1 / -1) away from it.
local function cycle_terminal(step)
  local ring = terminal_ring()
  if #ring == 0 then
    vim.notify("No floating terminals", vim.log.levels.WARN)
    return
  end

  local cur_buf = vim.api.nvim_get_current_buf()
  local idx
  for i, entry in ipairs(ring) do
    if entry.buf == cur_buf then
      idx = i
      break
    end
  end

  if idx then
    ring[idx].hide()
  else
    -- Cursor is not in a ring terminal (e.g. normal mode in a code buffer): step from floaterm's
    -- current floaterm, as :FloatermNext would, or from just before the first entry if none.
    local fcur = vim.fn["floaterm#buflist#curr"]()
    idx = 0
    for i, entry in ipairs(ring) do
      if entry.buf == fcur then
        idx = i
        break
      end
    end
    if idx == 0 and step < 0 then
      idx = 1
    end
  end

  ring[(idx - 1 + step) % #ring + 1].show()
end

return {
  {
    "voldikss/vim-floaterm",
    config = function()
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8
    end,
    keys = {
      { "<leader>tf", "<cmd>FloatermNew<cr>", desc = "New floating terminal" },
      -- tt/tn/tp are also mapped in terminal mode so they work mid-prompt. They are global `t` maps
      -- (not buffer-local ones set on TermOpen) so they also exist in terminals opened before
      -- floaterm was loaded, e.g. a Claude float started first thing in the session.
      { "<leader>tt", "<cmd>FloatermToggle<cr>", mode = { "n", "t" }, desc = "Toggle floating terminal" },
      {
        "<leader>tn",
        function() cycle_terminal(1) end,
        mode = { "n", "t" },
        desc = "Next floating terminal (incl. Claude/opencode)",
      },
      {
        "<leader>tp",
        function() cycle_terminal(-1) end,
        mode = { "n", "t" },
        desc = "Prev floating terminal (incl. Claude/opencode)",
      },
      { "<leader>tl", function() require("floaterm").pick() end, desc = "Pick floating terminal" },
    },
  },
}
