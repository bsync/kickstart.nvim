-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>;", function()
	require("snacks").picker.buffers()
end, { desc = "Buffer picker" })

vim.keymap.set("n", "<leader>e", function()
	local mf = require("mini.files")
	if not mf.close() then
		mf.open(vim.fn.getcwd(), true)
	end
end, { desc = "Explorer (cwd, toggle)" })
vim.keymap.set("n", "<leader>fG", function()
	require("snacks").picker.git_status()
end, { desc = "Find git-modified files" })
vim.keymap.del("n", "<leader>,")

vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
