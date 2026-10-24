return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",

		config = function()
			local ts = require("nvim-treesitter")

			ts.setup()

			ts.install({
				-- General
				"lua",
				"python",
				"rust",
				"c",
				"cpp",
				"c_sharp",

				-- Shell / config / git
				"bash",
				"fish",
				"toml",
				"sql",
				"diff",
				"gitcommit",
				"regex",

				-- Web
				"html",
				"css",
				"javascript",
				"typescript",
				"tsx",
				"json", -- also highlights .jsonc files
				"yaml",
				"markdown",
				"markdown_inline",
			})

			-- Enable Treesitter highlighting for every filetype that has a parser
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},
}
