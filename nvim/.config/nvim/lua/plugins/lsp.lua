-- mason.setup() puts its bin directory on PATH, which is how nvim finds the servers it installs.
require("mason").setup()

-- Per-server settings live in after/lsp/<name>.lua, which merges over nvim-lspconfig's defaults.
-- rust-analyzer is started by rustaceanvim, not enabled here.
vim.lsp.enable({
	"cssls",
	"eslint",
	"html",
	"jsonls",
	"lua_ls",
	"marksman",
	"tailwindcss",
	"vtsls",
	"yamlls",
})

require("crates").setup({
	lsp = { enabled = true, actions = true, completion = true, hover = true },
})

local prettier_fts = {
	"css",
	"graphql",
	"handlebars",
	"html",
	"javascript",
	"javascriptreact",
	"json",
	"jsonc",
	"less",
	"markdown",
	"markdown.mdx",
	"scss",
	"typescript",
	"typescriptreact",
	"vue",
	"yaml",
}
local formatters_by_ft = { lua = { "stylua" }, sh = { "shfmt" } }
for _, ft in ipairs(prettier_fts) do
	formatters_by_ft[ft] = { "prettier" }
end

require("conform").setup({
	formatters_by_ft = formatters_by_ft,
	-- prettier runs only in projects that have a prettier config
	formatters = { prettier = { require_cwd = true } },
	format_on_save = { timeout_ms = 3000, lsp_format = "fallback" },
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local bufnr = ev.buf
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/definition") then
			vim.keymap.set("n", "gd", function()
				Snacks.picker.lsp_definitions()
			end, { buffer = bufnr, desc = "Goto Definition" })
		end
		vim.keymap.set("n", "<leader>ca", function()
			require("utils.claude_code_action").code_action_with_claude(false)
		end, { buffer = bufnr, desc = "Code Action (with Claude Code)" })
		-- :<C-u> exits visual mode and sets '< '> marks reliably
		vim.keymap.set(
			"x",
			"<leader>ca",
			[[:<C-u>lua require("utils.claude_code_action").code_action_with_claude(true)<CR>]],
			{ buffer = bufnr, silent = true, desc = "Code Action (with Claude Code)" }
		)
	end,
})
