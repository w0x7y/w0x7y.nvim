return {
	-- RevoFMT
	{
		"w0x7y/revofmt.nvim",
		main = "revofmt",
		lazy = false,
		opts = {
			indent_width = 4, -- 1 to 8 spaces
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
			labels = "asdfghjklqwertyuiopzxcvbnm",

			search = {
				multi_window = true,
				forward = true,
				wrap = true,
			},

			jump = {
				jumplist = true,
				pos = "start",
				history = false,
				register = false,
				nohlsearch = false,
				autojump = false,
			},

			modes = {
				char = {
					enabled = true,
					jump_labels = true,
					multi_line = true,
				},
			},

			highlight = {
				backdrop = true,
				matches = true,
			},
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
		},
	},
	-- Which-key: popup of available keybindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix", -- compact single-column panel, bottom-right
			-- No popup while typing; open it on demand with :? (see init.lua)
			triggers = {},
			spec = {
				{ "<leader>f", group = "Find" },
				{ "<leader>g", group = "Git" },
				{ "<leader>j", group = "Format" },
			},
		},
		config = function(_, opts)
			require("which-key").setup(opts)

			-- Drop the lighter float background so the popup blends with the editor
			local function clear_bg()
				local base = { WhichKeyNormal = "NormalFloat", WhichKeyBorder = "FloatBorder", WhichKeyTitle = "FloatTitle" }
				for group, from in pairs(base) do
					local hl = vim.api.nvim_get_hl(0, { name = from, link = false })
					hl.bg = nil
					vim.api.nvim_set_hl(0, group, hl)
				end
			end
			clear_bg()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_bg })
		end,
	},

	-- Mini notifyer
	{ "nvim-mini/mini.notify", version = "*" },

	-- Render markdown
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			-- Basic configuration goes here (or leave empty for defaults)
			enabled = true,
			file_types = { "markdown" },
		},
	},

	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local telescope = require("telescope")

			telescope.setup({
				defaults = {
					-- Options: 'horizontal', 'vertical', 'center', 'cursor'
					layout_strategy = "horizontal", -- Use horizontal layout for search results
					layout_config = {
						horizontal = {
							prompt_position = "bottom", -- Put search bar at the bottom
							preview_width = 0.55,
						},
					},
					sorting_strategy = "ascending", -- Best match at the top of the results list

					-- Keeps the UI clean by showing the filename first, then the path
					path_display = { "filename_first" },

					-- Ignore folders you don't want to search through
					file_ignore_patterns = { "node_modules", ".git/", "bin/", "obj/" },
				},
			})

			-- Keymaps
			vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Find buffers" })
		end,
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

			-- Enable Treesitter highlighting
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"lua",
					"python",
					"rust",
					"c",
					"cpp",
					"cs",

					"html",
					"css",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"json",
					"jsonc",
					"yaml",
					"markdown",
				},

				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},

	-- Mason
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- Automatically install LSPs + formatters
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},

		config = function()
			require("mason-tool-installer").setup({
				-- LSPs are installed by mason-lspconfig below
				ensure_installed = {
					-- Formatters
					"stylua",
					"csharpier",
					"clang-format",
					"black",
					"prettier",
				},
			})
		end,
	},

	-- Auto-completion
	{
		"hrsh7th/nvim-cmp",

		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",

			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},

		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- Don't let <Tab> jump back into snippets you already left
			luasnip.config.setup({
				region_check_events = "InsertEnter",
				delete_check_events = "TextChanged",
			})

			-- HTML / CSS / JS snippets from friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),

					-- Enter confirms only if you selected something
					["<CR>"] = cmp.mapping.confirm({
						select = false,
					}),

					-- Tab = next completion/snippet
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),

					-- Shift+Tab = previous completion/snippet
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				sources = cmp.config.sources({
					{
						name = "nvim_lsp",
					},
					{
						name = "luasnip",
					},
					{
						name = "path",
					},
				}, {
					{
						name = "buffer",
					},
				}),
			})
		end,
	},

	-- Mason LSP config
	{
		"williamboman/mason-lspconfig.nvim",

		dependencies = {
			"williamboman/mason.nvim",
		},

		config = function()
			require("mason-lspconfig").setup({
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
			})
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",

		dependencies = {
			"williamboman/mason-lspconfig.nvim",

			-- IMPORTANT:
			-- Make sure completion exists before cmp_nvim_lsp is used.
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},

		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- C#
			vim.lsp.config("omnisharp", {
				cmd = {
					"omnisharp",
				},

				capabilities = capabilities,
			})

			-- Lua
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,

				settings = {
					Lua = {
						diagnostics = {
							globals = {
								"vim",
							},
						},
					},
				},
			})

			-- JavaScript / TypeScript / JSX / TSX / React
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
			})

			-- ESLint
			vim.lsp.config("eslint", {
				capabilities = capabilities,
			})

			-- HTML
			vim.lsp.config("html", {
				capabilities = capabilities,
			})

			-- CSS
			vim.lsp.config("cssls", {
				capabilities = capabilities,
			})

			-- JSON
			vim.lsp.config("jsonls", {
				capabilities = capabilities,
			})

			-- clangd
			vim.lsp.config("clangd", {
				capabilities = capabilities,
			})

			-- Python
			vim.lsp.config("pyright", {
				capabilities = capabilities,
			})

			-- Rust
			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,
			})

			vim.lsp.enable({
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
			})
		end,
	},

	-- Formatter
	{
		"stevearc/conform.nvim",

		event = {
			"BufReadPre",
			"BufNewFile",
		},

		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					-- Lua
					lua = {
						"stylua",
					},

					-- C#
					cs = {
						"csharpier",
					},

					-- C / C++
					c = {
						"clang-format",
					},

					cpp = {
						"clang-format",
					},

					-- Python
					python = {
						"black",
					},

					-- Rust
					rust = {
						"rustfmt",
					},

					-- HTML
					html = {
						"prettier",
					},

					-- CSS
					css = {
						"prettier",
					},

					scss = {
						"prettier",
					},

					-- JavaScript
					javascript = {
						"prettier",
					},

					-- React JSX
					javascriptreact = {
						"prettier",
					},

					-- TypeScript
					typescript = {
						"prettier",
					},

					-- React TSX
					typescriptreact = {
						"prettier",
					},

					-- JSON
					json = {
						"prettier",
					},

					jsonc = {
						"prettier",
					},

					-- Markdown
					markdown = {
						"prettier",
					},

					-- YAML
					yaml = {
						"prettier",
					},
				},

				formatters = {
					["clang-format"] = {
						prepend_args = {
							"--style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
						},
					},

					["prettier"] = {
						prepend_args = {
							"--tab-width",
							"4",
						},
					},
				},

				-- Format automatically on save
				format_on_save = {
					lsp_format = "fallback",
					async = false,
					timeout_ms = 1000,
				},
			})

			-- Manual format: <leader>jf
			vim.keymap.set(
				{
					"n",
					"v",
				},
				"<leader>jf",
				function()
					conform.format({
						lsp_format = "fallback",
						async = false,
						timeout_ms = 1000,
					})
				end,
				{
					desc = "Format file or range",
				}
			)
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
				},
			})
		end,
	},

	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},

	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- Auto close + auto rename HTML tags
	{
		"windwp/nvim-ts-autotag",
		event = {
			"BufReadPre",
			"BufNewFile",
		},
		opts = {
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true, -- typing </ also closes the open tag
			},
		},
	},

	-- Commenting
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",

		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},

		config = function()
			require("nvim-tree").setup({
				view = {
					width = 30,
					side = "left",
					number = false,
					relativenumber = false,
				},

				filters = {
					dotfiles = false,

					custom = {
						"^.git$",
						"node_modules",
						".cache",
					},
				},

				git = {
					enable = true,
					ignore = false,
				},

				renderer = {
					icons = {
						show = {
							git = true,
							folder = true,
							file = true,
							folder_arrow = true,
						},
					},

					indent_markers = {
						enable = true,
					},

					highlight_git = true,
					highlight_opened_files = "name",
				},

				diagnostics = {
					enable = true,
					show_on_dirs = true,

					icons = {
						hint = "󰌵",
						info = "󰋼",
						warning = "",
						error = "",
					},
				},

				update_focused_file = {
					enable = true,
					update_root = false,
				},

				disable_netrw = true,
				hijack_netrw = true,
			})

			vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {
				desc = "Toggle file explorer",
			})
		end,
	},

	-- Snacks.nvim
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			terminal = {
				shell = "fish",
				win = {
					position = "right",
					width = 0.4,
				},
			},
			image = {
				doc = {
					inline = false, -- show it in a popup next to the cursor instead of in the buffer
					max_width = 10, -- make the preview smaller (defaults are 80 x 40)
					max_height = 10,
				},
			},

			bigfile = { enabled = true },
			dashboard = { enabled = true },
			indent = {
				animate = {
					enabled = vim.fn.has("nvim-0.10") == 1,
					style = "out",
					easing = "linear",
					duration = {
						step = 5, -- ms per step
						total = 500, -- maximum duration
					},
				},
			},
			lazygit = { enabled = true },
			quickfile = { enabled = true }, -- Instantly loads file text before heavy extensions run
			animate = { enabled = true },
			scroll = { enabled = true },
			words = { enabled = true }, -- Highlights matching variables under cursor
		},
		keys = {
			-- Shortcut to open the floating LazyGit window (<leader>gg)
			{
				"<leader>gg",
				function()
					require("snacks").lazygit()
				end,
				desc = "LazyGit",
			},

			-- Shortcut to open LazyGit history for the current file (<leader>gf)
			{
				"<leader>gf",
				function()
					require("snacks").lazygit.log_file()
				end,
				desc = "LazyGit Current File History",
			},
		},
	},

	-- BetterSQL.nvim
	{
		"w0x7y/better-sql.nvim",
		main = "better_sql",
		lazy = false,
		opts = {
			python = vim.fn.expand("~/.local/share/better-sql-venv/bin/python"),
			connections = {
				supabase = "host=aws-0-eu-central-1.pooler.supabase.com port=5432 dbname=postgres user=postgres.zurpazevlvtylnzvagoo sslmode=require",
			},
		},
	},
}
