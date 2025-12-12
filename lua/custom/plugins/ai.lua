return {
  'NickvanDyke/opencode.nvim',
  lazy=false,
  dependencies = {
    -- Recommended for `ask()`, and required for `toggle()` — otherwise optional
    { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
  },
  config = function()
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`
    }

    -- Required for `opts.auto_reload`
    vim.opt.autoread = true
  end
}
