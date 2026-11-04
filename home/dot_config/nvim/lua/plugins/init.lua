local gh = require("utils").gh

-- The one place that lists every plugin. confirm = false: all sources are GitHub repos named
-- here, so the install prompt adds nothing and would block a fresh machine or a headless run.
vim.pack.add({
	-- libraries
	{ src = gh("nvim-lua/plenary.nvim") },
	{ src = gh("lewis6991/async.nvim") }, -- refactoring.nvim needs it on nvim 0.12
	{ src = gh("MunifTanjim/nui.nvim") },
	{ src = gh("nvim-mini/mini.icons") },

	-- ui
	{ src = gh("rebelot/kanagawa.nvim") },
	{ src = gh("folke/snacks.nvim") },
	{ src = gh("folke/noice.nvim") },
	{ src = gh("folke/which-key.nvim") },
	{ src = gh("akinsho/bufferline.nvim") },
	{ src = gh("nvim-lualine/lualine.nvim") },
	{ src = gh("folke/zen-mode.nvim") },
	{ src = gh("karb94/neoscroll.nvim") },
	{ src = gh("sphamba/smear-cursor.nvim") },
	{ src = gh("Bekaboo/dropbar.nvim") },

	-- treesitter
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	{ src = gh("nvim-treesitter/nvim-treesitter-context") },
	{ src = gh("HiPhish/rainbow-delimiters.nvim") },
	{ src = gh("windwp/nvim-ts-autotag") },

	-- lsp, formatting and completion
	{ src = gh("neovim/nvim-lspconfig") },
	{ src = gh("mason-org/mason.nvim") },
	{ src = gh("b0o/SchemaStore.nvim") },
	{ src = gh("mrcjkb/rustaceanvim") },
	{ src = gh("saecki/crates.nvim") },
	{ src = gh("stevearc/conform.nvim") },
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
	{ src = gh("rafamadriz/friendly-snippets") },

	-- editing
	{ src = gh("stevearc/oil.nvim") },
	{ src = gh("folke/flash.nvim") },
	{ src = gh("kylechui/nvim-surround") },
	{ src = gh("nvim-mini/mini.pairs") },
	{ src = gh("nvim-mini/mini.bracketed") },
	{ src = gh("nvim-mini/mini.hipatterns") },
	{ src = gh("monaqa/dial.nvim") },
	{ src = gh("ThePrimeagen/refactoring.nvim") },
	{ src = gh("hedyhli/outline.nvim") },
	{ src = gh("MagicDuck/grug-far.nvim") },
	{ src = gh("folke/trouble.nvim") },
	{ src = gh("folke/todo-comments.nvim") },
	{ src = gh("MeanderingProgrammer/render-markdown.nvim") },
	{ src = gh("greggh/claude-code.nvim") },
	{ src = gh("wakatime/vim-wakatime") },

	-- git
	{ src = gh("dinhhuy258/git.nvim") },
	{ src = gh("lewis6991/gitsigns.nvim") },
	{ src = gh("sindrets/diffview.nvim") },
}, { confirm = false })

-- Per-machine settings (git-ignored). Runs after vim.pack.add so it can add plugins, and
-- before the setup() calls so it can set variables they read.
if vim.uv.fs_stat(vim.fn.stdpath("config") .. "/lua/plugins/local.lua") then
	require("plugins.local")
end

require("plugins.ui")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.completion")
require("plugins.editor")
require("plugins.git")
