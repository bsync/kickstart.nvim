return {
  'NickvanDyke/opencode.nvim',
  lazy = false,
  dependencies = {
    -- Recommended for `ask()`, and required for `toggle()` — otherwise optional
    { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
  },
  config = function()
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`
      provider = { enabled = 'snacks' },
    }
    vim.keymap.set({ 'n', 'x' }, '<leader>aa', function()
      require('opencode').ask('@this: ', { submit = true })
    end, { desc = 'Ask opencode' })
    vim.keymap.set({ 'n', 'x' }, '<leader>ac', function()
      require('opencode').select()
    end, { desc = 'Execute opencode action…' })
    vim.keymap.set({ 'n', 'x' }, 'ga', function()
      require('opencode').prompt '@this'
    end, { desc = 'Add to opencode' })
    vim.keymap.set({ 'n', 't' }, '<leader>at', function()
      require('opencode').toggle()
    end, { desc = 'Toggle opencode' })
    vim.keymap.set('n', '<S-C-u>', function()
      require('opencode').command 'session.half.page.up'
    end, { desc = 'opencode half page up' })
    vim.keymap.set('n', '<S-C-d>', function()
      require('opencode').command 'session.half.page.down'
    end, { desc = 'opencode half page down' })

    -- Required for `opts.auto_reload`
    vim.opt.autoread = true
  end,
}
