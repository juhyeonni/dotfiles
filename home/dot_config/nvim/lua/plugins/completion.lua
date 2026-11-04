require("blink.cmp").setup({
	keymap = { preset = "enter" },
	signature = { enabled = true, window = { winblend = vim.o.pumblend } },
	completion = {
		menu = { winblend = vim.o.pumblend },
		documentation = { auto_show = true },
	},
})

-- Ctrl+Space: show completion menu in insert mode (override <C-@> default)
vim.keymap.set("i", "<C-@>", function()
	require("blink.cmp").show()
end, { desc = "Show completion menu" })
