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
vim.keymap.set("n", "<leader>fG", function()
	require("snacks").picker.git_status()
end, { desc = "Find git-modified files" })
-- Gitsigns lives under <leader>gs; the buffer-local half is in plugins/git.lua.
vim.keymap.set("n", "<leader>gsq", function()
	require("gitsigns").setqflist("all", { open = true })
end, { desc = "Quickfix all git hunks (repo-wide)" })
-- Point gitsigns gutters at the merge-base with integration (three-dot review
-- semantics) so hunks reflect only this branch's changes. Falls back to the
-- local `integration` ref when there is no `origin/integration`.
vim.keymap.set("n", "<leader>gsi", function()
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
end, { desc = "Gitsigns: diff vs integration merge-base" })
vim.keymap.set("n", "<leader>gsI", function()
	require("gitsigns").change_base(nil, true)
	vim.notify("gitsigns base → index")
end, { desc = "Gitsigns: reset base to index" })
vim.keymap.del("n", "<leader>,")
vim.keymap.del("n", "<leader>fT")

vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
