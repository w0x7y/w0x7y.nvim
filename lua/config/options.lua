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
-- Neovim's default cursor shapes, but an underline in visual mode
vim.opt.guicursor = "n-c-sm:block,i-ci-ve:ver25,v-r-cr-o:hor20,t:block-blinkon500-blinkoff500-TermCursor"
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

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
-- Stop the built-in ftplugins from switching these filetypes to 4 spaces or tabs
vim.g.python_recommended_style = 0
vim.g.rust_recommended_style = 0
vim.g.markdown_recommended_style = 0
vim.g.go_recommended_style = 0

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Tab / Shift-Tab indent the selection and keep it selected for repeated presses
vim.keymap.set("x", "<Tab>", ">gv", { desc = "Indent selection" })
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = "Dedent selection" })
