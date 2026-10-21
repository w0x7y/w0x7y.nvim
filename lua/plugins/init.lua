-- Size a bottom-bar picker to its results, up to the screen height
local function fit_height(picker)
	local update = picker.list.update
	picker.list.update = function(list, ...)
		local rows = vim.o.lines - vim.o.cmdheight - 2 -- leave room for the top outline and the prompt
		local height = math.max(math.min(list:count(), rows), 1) + 1 -- results + the prompt
		if picker.layout.opts.layout.height ~= height then
			picker.layout.opts.layout.height = height
			for _, box in ipairs(picker.layout.opts.layout) do
				if box.win == "list" then
					box.height = height - 1 -- vim.ui.select sets a fixed list height; keep it in step
				end
			end
			picker.layout:update()
			-- The layout resizes with events off, so the list never hears about its new height
			list.state.height = vim.api.nvim_win_get_height(list.win.win)
			list.dirty = true
		end
		update(list, ...)
	end
	picker.list:update() -- results that arrived before the picker showed
end

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
		opts = {
			-- Basic configuration goes here (or leave empty for defaults)
			enabled = true,
			file_types = { "markdown" },
		},
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
		config = function()
			require("mason").setup()
		end,
	},

	-- Automatically install LSPs + formatters
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy", -- checks installs after the UI is up
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

	-- Snippets
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},

		config = function()
			-- Don't let <Tab> jump back into snippets you already left
			require("luasnip").config.setup({
				region_check_events = "InsertEnter",
				delete_check_events = "TextChanged",
			})

			-- HTML / CSS / JS snippets from friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			-- Revo snippets in snippets/
			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
		end,
	},

	-- Auto-completion (also sets LSP completion capabilities for every server)
	{
		"saghen/blink.cmp",
		version = "1.*", -- release tags ship the prebuilt fuzzy matcher
		dependencies = {
			"L3MON4D3/LuaSnip",
		},
		opts = {
			snippets = { preset = "luasnip" },

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
						override = {
							-- Clear "@trigger" as part of the expansion. Deleting the @ afterwards
							-- shifts the text left and the placeholder selection lands one char off
							execute = function(source, ctx, item, callback, default)
								local row, col = unpack(vim.api.nvim_win_get_cursor(0))
								local at = vim.api.nvim_get_current_line():sub(1, col):find("@[^%s@]*$")
								if at then
									local luasnip = require("luasnip")
									luasnip.snip_expand(luasnip.get_id_snippet(item.data.snip_id), {
										clear_region = { from = { row - 1, at - 1 }, to = { row - 1, col } },
									})
								else
									source:execute(ctx, item, function() end, default)
								end
								callback()
							end,
						},
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

	-- LSP: server defaults come from nvim-lspconfig, mason-lspconfig enables
	-- every installed server, and blink.cmp adds completion capabilities
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },

		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},

		config = function()
			-- C#
			vim.lsp.config("omnisharp", {
				cmd = {
					"omnisharp",
				},
			})
		end,
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
					globalstatus = true, -- one statusline across all splits
					section_separators = { left = "", right = "" },
					component_separators = "",
				},
				sections = {
					lualine_x = {
						-- showmode is off and the command bar is hidden, so show macro recording here
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
			quickfile = { enabled = true }, -- Instantly loads file text before heavy extensions run
			animate = { enabled = true },
			scroll = { enabled = true },
			words = { enabled = true }, -- Highlights matching variables under cursor
			input = { enabled = true }, -- Nicer vim.ui.input (LSP rename prompt)
			explorer = { enabled = true }, -- File explorer, also opens on `nvim <dir>`
			-- Show image files (and markdown images) through kitty's graphics protocol
			image = {
				enabled = true,
				doc = { max_width = 40, max_height = 15 }, -- markdown images, in cells
			},

			-- Fuzzy finder; also styles vim.ui.select (code actions)
			picker = {
				-- Looks like :find in the command line: a plain list above a prompt on the last line
				layout = { preset = "cmdline" },
				layouts = {
					cmdline = {
						reverse = true, -- best match sits right above the prompt
						layout = {
							box = "vertical",
							backdrop = false,
							-- Bottom row on lualine, which drops to the last line when cmdheight is 0
							row = function(win)
								return vim.o.lines - vim.o.cmdheight - 1 - win.opts.height
							end,
							width = 0,
							height = 4, -- starting size; fit_height resizes it to the results
							border = "top",
							-- Thin top line in the split-separator color
							wo = { winhighlight = "NormalFloat:Normal,FloatBorder:WinSeparator" },
							-- Editor background, like the real command line
							{
								win = "list",
								border = "none",
								wo = { winhighlight = "NormalFloat:Normal,CursorLine:Visual" },
							},
							{
								win = "input",
								height = 1,
								border = "none",
								wo = { winhighlight = "NormalFloat:Normal" },
							},
						},
					},
				},
				icons = { files = { enabled = false } },
				sources = {
					-- Ignore folders you don't want to search through
					files = { prompt = ":find ", exclude = { "node_modules", "bin", "obj" }, on_show = fit_height },
					grep = { prompt = ":grep ", exclude = { "node_modules", "bin", "obj" }, on_show = fit_height },
					buffers = { prompt = ":buffer ", on_show = fit_height },
					keymaps = { prompt = ":map ", on_show = fit_height },
					lsp_references = { prompt = ":references ", on_show = fit_height },
					-- vim.ui.select (code actions, confirmations): its title becomes the prompt
					select = {
						layout = { preset = "cmdline" },
						on_show = function(picker)
							picker.opts.prompt = picker.opts.title .. " "
							picker.input:update()
							fit_height(picker)
						end,
					},
					explorer = {
						icons = { files = { enabled = true } },
						hidden = true, -- show dotfiles; gitignored files stay hidden (press I to show)
						exclude = { ".git", "node_modules", ".cache" },
						jump = { close = true }, -- close after opening a file
						-- No search bar; press / in the explorer to search
						layout = { hidden = { "input" }, layout = { width = 24, min_width = 24 } },
					},
				},
			},
		},
		config = function(_, opts)
			local Snacks = require("snacks")
			Snacks.setup(opts)

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

			-- Every vim.ui.input prompt (LSP rename, explorer rename/add/copy) on the bottom line, like <leader>ff
			local input = Snacks.input.input
			local function cmdline_input(o, on_confirm)
				-- LSP's "New Name", explorer's "New File Name", "Add a new file ..." and "Copy to"
				local prompt = ({ New = ":rename ", Add = ":new ", Copy = ":copy " })[(o.prompt or ""):match("%a+")]
					or o.prompt
					or ""
				local win = input(
					vim.tbl_extend("force", o, {
						icon = "",
						prompt_pos = false,
						expand = false,
						win = {
							row = vim.o.lines - vim.o.cmdheight - 2, -- over lualine, where <leader>ff types
							col = 0,
							width = 0,
							border = "top",
							wo = { winhighlight = "NormalFloat:Normal,FloatBorder:WinSeparator" },
						},
					}),
					on_confirm
				)
				vim.wo[win.win].statuscolumn = "%#SnacksPickerPrompt#" .. prompt:gsub("%%", "%%%%") .. "%*"
				return win
			end
			Snacks.input.input = cmdline_input
			vim.ui.input = cmdline_input

			-- Delete/move confirmations: the select source puts them in the bottom bar.
			-- Same as snacks' own, minus its 60-column width cap.
			Snacks.picker.util.confirm = function(prompt, fn)
				Snacks.picker.select({ "No", "Yes" }, { prompt = prompt }, function(_, idx)
					if idx == 2 then
						fn()
					end
				end)
			end
		end,
		keys = {
			-- Finder
			{
				"<leader>ff",
				function()
					require("snacks").picker.files()
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					require("snacks").picker.grep()
				end,
				desc = "Live grep",
			},
			{
				"<leader>fb",
				function()
					require("snacks").picker.buffers()
				end,
				desc = "Find buffers",
			},
			{
				"<leader>fk",
				function()
					require("snacks").picker.keymaps()
				end,
				desc = "Find keymaps",
			},
			{
				"grr",
				function()
					require("snacks").picker.lsp_references()
				end,
				desc = "References",
			},

			-- File explorer
			{
				"<leader>e",
				function()
					require("snacks").explorer()
				end,
				desc = "Toggle file explorer",
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
				supabase = "service=supabase", -- host/user live in ~/.pg_service.conf, password in ~/.pgpass
			},
		},
	},
}
