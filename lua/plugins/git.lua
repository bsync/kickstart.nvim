return {
  -- Global gitsigns maps; the buffer-local half is in the on_attach further down.
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<leader>gn", "<cmd>Gitsigns next_hunk<cr>", desc = "Next hunk" },
      { "<leader>gp", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev hunk" },
      {
        "<leader>gsq",
        function()
          require("gitsigns").setqflist("all", { open = true })
        end,
        desc = "Quickfix all git hunks (repo-wide)",
      },
      -- Point gitsigns gutters at the merge-base with integration (three-dot review
      -- semantics) so hunks reflect only this branch's changes. Falls back to the
      -- local `integration` ref when there is no `origin/integration`.
      {
        "<leader>gsi",
        function()
          local base = vim.fn.system("git merge-base origin/integration HEAD"):gsub("%s+", "")
          if vim.v.shell_error ~= 0 or base == "" then
            base = vim.fn.system("git merge-base integration HEAD"):gsub("%s+", "")
          end
          if vim.v.shell_error ~= 0 or base == "" then
            vim.notify("Could not find a merge-base with integration", vim.log.levels.ERROR)
            return
          end
          require("gitsigns").change_base(base, true)
          vim.notify("gitsigns base → integration merge-base (" .. base:sub(1, 8) .. ")")
        end,
        desc = "Gitsigns: diff vs integration merge-base",
      },
      -- Same idea one commit back: gutters show only what the most recent commit changed.
      -- Resolved to a SHA rather than passing "HEAD~1" through, so the base stays put if you
      -- commit again while it is set -- otherwise it would silently slide forward under you.
      -- Not <leader>gsp: that is the buffer-local Preview Hunk Inline, which would shadow it.
      {
        "<leader>gsc",
        function()
          local base = vim.fn.system("git rev-parse --verify --short=8 HEAD~1"):gsub("%s+", "")
          if vim.v.shell_error ~= 0 or base == "" then
            vim.notify("No previous commit (HEAD may be the root commit)", vim.log.levels.ERROR)
            return
          end
          require("gitsigns").change_base(base, true)
          vim.notify("gitsigns base → previous commit (" .. base .. ")")
        end,
        desc = "Gitsigns: diff vs previous commit",
      },
      {
        "<leader>gsx",
        function()
          require("gitsigns").change_base(nil, true)
          vim.notify("gitsigns base → index")
        end,
        desc = "Gitsigns: reset base to index",
      },
    },
  },
  { 'tpope/vim-fugitive',
    lazy = false,
  },
  -- Free up <leader>gd (Git Diff hunks) and <leader>gs (Git Status) from the
  -- LazyVim Snacks picker defaults so they can act as the diffview / gitsigns
  -- prefixes — git status moves to <leader>fG. <leader>gD (Git Diff origin) stays
  -- disabled to keep the top-level <leader>g namespace to one key per plugin;
  -- everything diffview is under <leader>gd*.
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>gd", false },
      { "<leader>gD", false },
      { "<leader>gs", false },
      { "<leader>fG", function() Snacks.picker.git_status() end, desc = "Find git-modified files" },
    },
  },
  -- <leader>gd and <leader>gs are the diffview / gitsigns groups; LazyVim's
  -- <leader>gh "hunks" group is gone.
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      for _, group in ipairs(opts.spec) do
        for i = #group, 1, -1 do
          if type(group[i]) == "table" and group[i][1] == "<leader>gh" then
            table.remove(group, i)
          end
        end
      end
      table.insert(opts.spec, {
        mode = { "n", "x" },
        { "<leader>gd", group = "diff view" },
        { "<leader>gs", group = "gitsigns" },
      })
    end,
  },
  -- Free up ]c / [c from treesitter class navigation so gitsigns can claim them.
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      for _, dir in ipairs({ "goto_next_start", "goto_next_end", "goto_previous_start", "goto_previous_end" }) do
        local keys = vim.tbl_get(opts, "move", "keys", dir)
        if keys then
          keys["]c"], keys["[c"] = nil, nil
        end
      end
    end,
  },
  -- Own the whole gitsigns on_attach rather than chaining LazyVim's: its hunk
  -- actions live under <leader>gh, and buffer-local maps can't be cleanly removed
  -- after the fact. Everything below is the LazyVim set rehomed to <leader>gs,
  -- plus this config's own review bindings.
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts.on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        -- Navigation: ]h/[h and ]c/[c both walk hunks (]c/[c falls through to
        -- vim's own diff motions in a diff window); ]C/[C walk hunks with an
        -- auto-opened floating preview for reviewing.
        -- stylua: ignore start
        local function nav(dir, vimkey)
          return function()
            if vim.wo.diff then
              vim.cmd.normal({ vimkey, bang = true })
            else
              gs.nav_hunk(dir)
            end
          end
        end
        map("n", "]h", nav("next", "]c"), "Next Hunk")
        map("n", "[h", nav("prev", "[c"), "Prev Hunk")
        map("n", "]c", nav("next", "]c"), "Next Hunk")
        map("n", "[c", nav("prev", "[c"), "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map("n", "]C", function() gs.nav_hunk("next", { preview = true }) end, "Next Hunk (preview)")
        map("n", "[C", function() gs.nav_hunk("prev", { preview = true }) end, "Prev Hunk (preview)")
        map({ "n", "x" }, "<leader>gss", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>gsr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>gsS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gsu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gsR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gsp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>gsP", gs.preview_hunk, "Preview Hunk (float)")
        map("n", "<leader>gsb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>gsB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>gsd", gs.diffthis, "Diff This")
        map("n", "<leader>gsD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        -- stylua: ignore end
      end
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gdi", "<cmd>DiffviewOpen master...HEAD --imply-local<cr>", desc = "Diff vs main (incl. uncommitted)" },
      { "<leader>gdI", "<cmd>DiffviewOpen integration...HEAD --imply-local<cr>", desc = "Diff vs integration (incl. uncommitted)" },
      { "<leader>gdx", "<cmd>DiffviewOpen<cr>",                                  desc = "Diff working tree (uncommitted)" },
      { "<leader>gdD", "<cmd>DiffviewClose<cr>",                                 desc = "Close diffview" },
    },
    config = function()
      require("diffview").setup({
        diff_binaries = false,    -- Show diffs for binaries
        enhanced_diff_hl = true,  -- Better syntax highlighting
        use_icons = true,         -- Requires nvim-web-devicons
        signs = {
          fold_closed = "",
          fold_open = "",
        },
        file_panel = {
          listing_style = "tree",  -- One of 'list' or 'tree'
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
          },
        },
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                diff_merges = "combined",
              },
              multi_file = {
                diff_merges = "first-parent",
              },
            },
          },
          win_config = {
            position = "bottom",
            height = 16,
          },
        },
      })
    end,
  },
}
