-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>;", function()
	require("snacks").picker.buffers()
end, { desc = "Buffer picker" })

vim.keymap.set("n", "<leader>ft", function()
	local items = {}
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		local tabnr = vim.api.nvim_tabpage_get_number(tab)
		local win = vim.api.nvim_tabpage_get_win(tab)
		local buf = vim.api.nvim_win_get_buf(win)
		local bufname = vim.api.nvim_buf_get_name(buf)
		local name = bufname ~= "" and vim.fn.fnamemodify(bufname, ":~:.") or "[No Name]"
		local nwins = #vim.api.nvim_tabpage_list_wins(tab)
		items[#items + 1] = {
			text = tabnr .. " " .. name,
			tabnr = tabnr,
			name = name,
			nwins = nwins,
			current = tab == vim.api.nvim_get_current_tabpage(),
		}
	end
	require("snacks").picker.pick({
		title = "Tabs",
		items = items,
		format = function(item)
			local ret = {}
			ret[#ret + 1] = { ("%d"):format(item.tabnr), "SnacksPickerIdx" }
			ret[#ret + 1] = { item.current and " ● " or "   ", "SnacksPickerSpecial" }
			ret[#ret + 1] = { item.name, "SnacksPickerFile" }
			if item.nwins > 1 then
				ret[#ret + 1] = { (" (%d windows)"):format(item.nwins), "SnacksPickerComment" }
			end
			return ret
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				vim.cmd("tabnext " .. item.tabnr)
			end
		end,
	})
end, { desc = "Tab picker" })

vim.keymap.set("n", "<leader>e", function()
	local mf = require("mini.files")
	if not mf.close() then
		mf.open(vim.fn.getcwd(), true)
	end
end, { desc = "Explorer (cwd, toggle)" })
vim.keymap.del("n", "<leader>,")
vim.keymap.del("n", "<leader>fT")

vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
