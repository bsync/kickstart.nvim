-- Python-specific keymaps
-- Insert breakpoint at current line
vim.keymap.set("n", "<leader>db", "obreakpoint()", { buffer = true, desc = "Insert Python breakpoint" })

