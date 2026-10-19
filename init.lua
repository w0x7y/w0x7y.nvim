-- Leader key
vim.g.mapleader = " "

-- Key Binds
vim.keymap.set("n", "<leader>t", function()
	Snacks.terminal.toggle()
end, { desc = "Toggle Terminal" })

-- <leader>fc fuzzy-finds files in the real command line (:find + fd)
local find_files
function _G.FindFiles(arg)
	find_files = find_files or vim.fn.systemlist({ "fd", "--type", "f", "--hidden", "--exclude", ".git" })
	return arg == "" and find_files or vim.fn.matchfuzzy(find_files, arg)
end
vim.o.findfunc = "v:lua.FindFiles"
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		find_files = nil -- re-list on each new command line so new files show up
	end,
})
vim.keymap.set("n", "<leader>fc", ":find ", { desc = "Find files (command line)" })

-- gd for every LSP; the rest is built in: grn rename, gra code action, grr references, gri implementation, gO symbols, K hover
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to definition" })
	end,
})

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"
vim.opt.undofile = true -- undo history survives closing the file
vim.opt.scrolloff = 8
vim.opt.inccommand = "split" -- live preview of :%s/foo/bar
vim.opt.confirm = true -- :q on a modified buffer asks instead of erroring
vim.opt.cursorline = true
vim.opt.showmode = false -- lualine shows the mode

-- Looks
vim.opt.winborder = "rounded" -- hover, signature and diagnostic floats
vim.opt.fillchars = { eob = " " } -- no ~ after the end of the buffer
-- Full diagnostic message below the cursor's line only; no inline text on other lines
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = { current_line = true },
})

-- Experimental 0.12 message/cmdline UI: no "Press ENTER" prompts
local ui2 = require("vim._core.ui2")
ui2.enable({})
vim.opt.cmdheight = 0

-- The command bar is hidden. A command or message brings it up, and it hides
-- again after 2 seconds without a new one.
local hide_bar = vim.uv.new_timer()
local function show_bar()
	if ui2.cmdheight == 0 then
		pcall(function() -- resizing windows isn't allowed in every context
			vim.o.cmdheight = 1
		end)
	end
	hide_bar:start(
		2000,
		0,
		vim.schedule_wrap(function()
			if vim.fn.mode() == "c" then
				return show_bar() -- still typing a command
			end
			vim.o.cmdheight = 0
		end)
	)
end
local msg_show = ui2.msg.msg_show
ui2.msg.msg_show = function(...)
	show_bar()
	return msg_show(...)
end
vim.api.nvim_create_autocmd("CmdlineLeave", { callback = show_bar })

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Lazy bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")

-- Revo
-- language support
require("revo")
