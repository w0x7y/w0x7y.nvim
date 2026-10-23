-- Leader key
vim.g.mapleader = " "

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
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 250
vim.opt.signcolumn = "number" -- git/diagnostic signs replace the line number, no extra gutter
vim.opt.numberwidth = 1 -- number column only as wide as the line count needs
vim.opt.undofile = true -- undo history survives closing the file
vim.opt.scrolloff = 8
vim.opt.inccommand = "split" -- live preview of :%s/foo/bar
vim.opt.confirm = true -- :q on a modified buffer asks instead of erroring
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"
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
require("vim._core.ui2").enable({})

-- : commands get a fuzzy menu as you type; nothing is preselected, so <CR> runs what you typed
vim.opt.wildmode = "noselect:lastused,full"
vim.opt.wildoptions = "pum,fuzzy"
vim.api.nvim_create_autocmd("CmdlineChanged", {
	pattern = ":",
	callback = function()
		vim.fn.wildtrigger()
	end,
})

-- :find fuzzy-matches every file in the project (fd skips gitignored files)
local files
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		files = nil -- list files once per command line, not on every keystroke
	end,
})
function _G.Find(arg)
	files = files or vim.fn.systemlist({ "fd", "--type", "f", "-E", "node_modules", "-E", "bin", "-E", "obj" })
	return arg == "" and files or vim.fn.matchfuzzy(files, arg)
end
vim.opt.findfunc = "v:lua.Find"

-- :grep fills the quickfix list and opens it, one line per match up to 10 lines
vim.opt.grepprg = "rg --line-number --column --no-heading --smart-case --glob=!node_modules --glob=!bin --glob=!obj" -- one entry per matching line
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	pattern = "[^l]*",
	callback = function()
		vim.cmd.cwindow()
		local win = vim.fn.getqflist({ winid = 0 }).winid
		if win ~= 0 then -- cwindow leaves an already open window at its old height
			vim.api.nvim_win_set_height(win, math.min(#vim.fn.getqflist(), 10))
		end
	end,
})

-- Finder
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":silent grep ", { desc = "Grep" }) -- silent: don't print rg's raw output over the editor
vim.keymap.set("n", "<leader>fb", ":buffer ", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fk", "<cmd>map<CR>", { desc = "List keymaps" })
vim.keymap.set("n", "<leader>fd", vim.diagnostic.setqflist, { desc = "List diagnostics" })
vim.keymap.set("n", "<leader>e", "<cmd>Lexplore<CR>", { desc = "Toggle file explorer sidebar (netrw)" })
vim.g.netrw_banner = 0 -- no help header; I shows it again
vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_winsize = -30 -- negative: sidebar width in columns, not percent
vim.g.Netrw_funcref = function() -- runs after netrw opens a file
	if vim.t.netrw_lexbufnr then
		vim.cmd("Lexplore") -- picked from the sidebar: close it
	end
end

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
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
