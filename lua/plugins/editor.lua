return {
	-- Flash
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = { char = { jump_labels = true } },
		},

		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump({
						search = {
							mode = "search",
							max_length = 20,
						},
						label = {
							uppercase = true,
						},
					})
				end,
				desc = "Flash",
			},
			-- Select a treesitter node by label
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
		},
	},

	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
	},

	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},

	-- Auto close + auto rename HTML tags
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			opts = { enable_close_on_slash = true }, -- typing </ also closes the open tag
		},
	},
}
