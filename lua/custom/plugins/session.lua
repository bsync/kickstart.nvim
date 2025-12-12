return {
  'rmagatti/auto-session',
  lazy = false,

  ---enables autocomplete for opts
  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    suppressed_dirs = { '~/Projects', '~/Downloads', '/' },
    -- log_level = 'debug',
    auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    bypass_save_filetypes = { 'claude-code' },
    session_lens = {
      load_on_setup = true,
      theme_conf = { border = true },
      previewer = false,
    },
    pre_save_cmds = {
      function()
        -- Close claude-code buffers before saving session
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local buftype = vim.api.nvim_buf_get_option(buf, 'filetype')
          if buftype == 'claude-code' then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    },
  },
}
