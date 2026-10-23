return {
	-- RevoFMT
	{
		"w0x7y/revofmt.nvim",
		main = "revofmt",
		lazy = false,
		opts = {
			indent_width = 2, -- 1 to 8 spaces
			line_width = 80, -- 20 to 240 columns; a soft target
			format_on_save = true,
		},
		build = function()
			local ok, err = require("revofmt").install({ async = false })
			if not ok then
				error(err)
			end
		end,
	},
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

	-- Render markdown
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = "markdown",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},

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

	-- Mason
	{
		"williamboman/mason.nvim",
		cmd = "Mason", -- otherwise loads with the LSP setup below
		opts = {},
	},

	-- Automatically install LSPs + formatters
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy", -- checks installs after the UI is up
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = {
			-- LSPs are installed by mason-lspconfig below
			ensure_installed = {
				-- Formatters
				"stylua",
				"csharpier",
				"clang-format",
				"black",
				"prettier",
			},
		},
	},

	-- Auto-completion (also sets LSP completion capabilities for every server)
	{
		"saghen/blink.cmp",
		version = "1.*", -- release tags ship the prebuilt fuzzy matcher
		dependencies = {
			-- HTML / CSS / JS snippets; blink also loads the Revo snippets in snippets/
			"rafamadriz/friendly-snippets",
		},
		opts = {
			-- Enter confirms only if you selected something; Tab = next completion/snippet
			keymap = {
				preset = "enter",
				["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			},

			-- Minimal look: plain list of label + kind, no border, no scrollbar,
			-- no popups unless asked (<C-space> toggles docs, built-in <C-s> shows the signature)
			completion = {
				list = { selection = { preselect = false } },
				menu = {
					border = "none",
					scrollbar = false,
					draw = { columns = { { "label" }, { "kind" } } },
				},
				documentation = { auto_show = false },
			},

			signature = { enabled = false },

			-- The built-in wildmenu completes the command line (see init.lua)
			cmdline = { enabled = false },

			-- Snippets only show after an @ (@for); the normal menu has none
			sources = {
				default = function()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					local after_at = vim.api.nvim_get_current_line():sub(1, col):find("@[^%s@]*$")
					return after_at and { "snippets" } or { "lsp", "path", "buffer" }
				end,
				providers = {
					lsp = {
						transform_items = function(_, items)
							local snippet = require("blink.cmp.types").CompletionItemKind.Snippet
							return vim.tbl_filter(function(item)
								return item.kind ~= snippet
							end, items)
						end,
					},
					snippets = {
						-- Stretch each snippet's edit back over the @ so expanding replaces "@for", not just "for"
						transform_items = function(ctx, items)
							local at = ctx.line:sub(1, ctx.cursor[2]):find("@[^%s@]*$")
							for _, item in ipairs(at and items or {}) do
								item.textEdit.range.start.character = at - 1
							end
							return items
						end,
					},
				},
			},
		},
	},

	-- Mason LSP config
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = true, -- loaded by nvim-lspconfig
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = {
			ensure_installed = {
				"clangd",
				"omnisharp",
				"lua_ls",
				"pyright",
				"rust_analyzer",

				-- Web
				"html",
				"cssls",
				"ts_ls",
				"eslint",
				"jsonls",
			},
		},
	},

	-- LSP: server defaults come from nvim-lspconfig, mason-lspconfig enables
	-- every installed server, and blink.cmp adds completion capabilities
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },

		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
	},

	-- Lua LSP knows the Neovim API and your installed plugins (replaces globals = { "vim" })
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "snacks.nvim", words = { "Snacks" } },
			},
		},
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					cs = { "csharpier" },
					c = { "clang-format" },
					cpp = { "clang-format" },
					python = { "black" },
					rust = { "rustfmt" },
					html = { "prettier" },
					css = { "prettier" },
					scss = { "prettier" },
					javascript = { "prettier" },
					javascriptreact = { "prettier" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
					json = { "prettier" },
					jsonc = { "prettier" },
					markdown = { "prettier" },
					yaml = { "prettier" },
				},

				formatters = {
					["clang-format"] = {
						prepend_args = { "--style={BasedOnStyle: LLVM, IndentWidth: 2, TabWidth: 2, UseTab: Never}" },
					},
					prettier = { prepend_args = { "--tab-width", "2" } },
					stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" } },
					rustfmt = { prepend_args = { "--config", "tab_spaces=2" } },
				},

				-- Format automatically on save
				format_on_save = { lsp_format = "fallback", timeout_ms = 1000 },
			})

			-- Manual format: <leader>jf
			vim.keymap.set({ "n", "v" }, "<leader>jf", function()
				conform.format({ lsp_format = "fallback", timeout_ms = 1000 })
			end, { desc = "Format file or range" })
		end,
	},

	-- Better status line(Lualine)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					icons_enabled = true,
					globalstatus = true, -- one statusline across all splits
					section_separators = { left = "", right = "" },
					component_separators = "",
				},
				sections = {
					lualine_x = {
						-- showmode is off, so show macro recording here
						{
							function()
								return "recording @" .. vim.fn.reg_recording()
							end,
							cond = function()
								return vim.fn.reg_recording() ~= ""
							end,
							color = "WarningMsg",
						},
						"encoding",
						"fileformat",
						"filetype",
					},
				},
			})
			vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
				callback = function()
					vim.schedule(require("lualine").refresh) -- the register is still set during RecordingLeave
				end,
			})
		end,
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

	-- Snacks.nvim
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			dashboard = {
				enabled = true,
				sections = {
					{ text = { "cold", hl = "Title" }, align = "center", padding = 1 },
					{
						align = "center",
						-- Rime's icon snowflake in braille, colored per arm: Directory blue, Special cyan, Define violet
						text = {
							{ "               ⣾⣶⣿⣿⣶⣷               \n", hl = "Directory" },
							{ "              ⣀⡈⠻⣿⣿⠟⢁⣀              \n", hl = "Directory" },
							{ "              ⢻⣿⣦⣿⣿⣴⣿⡟              \n", hl = "Directory" },
							{ "   ⣀⡀          ", hl = "Special" },
							{ "⠙⢿⣿⣿⡿⠋          ", hl = "Directory" },
							{ "⢀⣀   \n", hl = "Define" },
							{ " ⣤⣼⣿⣷ ⣿⣷⡀        ", hl = "Special" },
							{ "⣿⣿        ", hl = "Directory" },
							{ "⢀⣾⣿ ⣾⣿⣧⣤ \n", hl = "Define" },
							{ "⢀⣽⣿⣿⣿⣧⣼⣿⣧        ", hl = "Special" },
							{ "⣿⣿        ", hl = "Directory" },
							{ "⣼⣿⣧⣼⣿⣿⣿⣯⡀\n", hl = "Define" },
							{ "⠈⠛⠉⣉⣉⣿⣿⣿⣿⣦⣀      ", hl = "Special" },
							{ "⣿⣿      ", hl = "Directory" },
							{ "⣀⣴⣿⣿⣿⣿⣉⣉⠉⠛⠁\n", hl = "Define" },
							{ "  ⠈⠿⠟⠛⠛⠋⠙⠻⢿⣷⣦⣄⡀  ", hl = "Special" },
							{ "⣿⣿  ", hl = "Directory" },
							{ "⢀⣠⣴⣾⡿⠟⠋⠙⠛⠛⠻⠿⠁  \n", hl = "Define" },
							{ "           ⠈⠛⠿⣿⣶", hl = "Special" },
							{ "⣤⣿⣿⣤", hl = "Normal" },
							{ "⣶⣿⠿⠛⠁           \n", hl = "Define" },
							{ "               ⣹", hl = "Special" },
							{ "⣿⣿⣿⣿", hl = "Normal" },
							{ "⣏               \n", hl = "Define" },
							{ "           ⢀⣤⣶⣿⠿", hl = "Define" },
							{ "⠛⣿⣿⠛", hl = "Normal" },
							{ "⠿⣿⣶⣤⡀           \n", hl = "Special" },
							{ "  ⢀⣶⣦⣤⣤⣄⣠⣴⣾⡿⠟⠋⠁  ", hl = "Define" },
							{ "⣿⣿  ", hl = "Directory" },
							{ "⠈⠙⠻⢿⣷⣦⣄⣠⣤⣤⣴⣶⡀  \n", hl = "Special" },
							{ "⢀⣤⣀⣉⣉⣿⣿⣿⣿⠟⠉      ", hl = "Define" },
							{ "⣿⣿      ", hl = "Directory" },
							{ "⠉⠻⣿⣿⣿⣿⣉⣉⣀⣤⡀\n", hl = "Special" },
							{ "⠈⣻⣿⣿⣿⡟⢻⣿⡟        ", hl = "Define" },
							{ "⣿⣿        ", hl = "Directory" },
							{ "⢻⣿⡟⢻⣿⣿⣿⣟⠁\n", hl = "Special" },
							{ " ⠛⢻⣿⡿ ⣿⡿⠁        ", hl = "Define" },
							{ "⣿⣿        ", hl = "Directory" },
							{ "⠈⢿⣿ ⢿⣿⡟⠛ \n", hl = "Special" },
							{ "   ⠉⠁          ", hl = "Define" },
							{ "⣠⣾⣿⣿⣷⣄          ", hl = "Directory" },
							{ "⠈⠉   \n", hl = "Special" },
							{ "              ⣼⣿⠟⣿⣿⠻⣿⣧              \n", hl = "Directory" },
							{ "              ⠉⢁⣴⣿⣿⣦⡈⠉              \n", hl = "Directory" },
							{ "               ⢿⠿⣿⣿⠿⡿               ", hl = "Directory" },
						},
					},
				},
			},
			indent = { animate = { enabled = false } }, -- indent guides, drawn without animation
			quickfile = { enabled = true }, -- Instantly loads file text before heavy extensions run
			words = { enabled = true }, -- Highlights matching variables under cursor
			-- Show image files (and markdown images) through kitty's graphics protocol
			image = {
				enabled = true,
				doc = { max_width = 40, max_height = 15 }, -- markdown images, in cells
			},
		},
		config = function(_, opts)
			require("snacks").setup(opts)

			-- Leaving an image file hides its picture, and snacks never un-hides it, so it came back blank
			local Placement = require("snacks.image.placement")
			local update = Placement.update
			Placement.update = function(self)
				if
					self.hidden
					and vim.api.nvim_buf_is_valid(self.buf)
					and vim.bo[self.buf].filetype == "image"
					and #self:wins() > 0
				then
					self.hidden = false
				end
				return update(self)
			end
		end,
	},

	-- BetterSQL.nvim
	{
		"w0x7y/better-sql.nvim",
		main = "better_sql",
		lazy = false,
		opts = {
			python = vim.fn.expand("~/.local/share/better-sql-venv/bin/python"),
			connections = {
				supabase = "service=supabase", -- host/user live in ~/.pg_service.conf, password in ~/.pgpass
			},
		},
	},
}
