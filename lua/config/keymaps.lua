-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>;", function()
	require("snacks").picker.buffers()
end, { desc = "Buffer picker" })

vim.keymap.set("n", "<leader>e", function()
	require("mini.files").open(vim.fn.getcwd(), true)
end, { desc = "Explorer (cwd)" })
vim.keymap.del("n", "<leader>,")
