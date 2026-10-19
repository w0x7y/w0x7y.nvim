-- Leader key
vim.g.mapleader = " "

-- Key Binds
vim.keymap.set("n", "<leader>t", function()
    Snacks.terminal.toggle()
end, { desc = "Toggle Terminal" })

-- :? opens which-key with the leader keymaps (<BS> in the popup shows all keymaps)
vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "?" then
        vim.schedule(function()
            require("which-key").show({ keys = "<leader>" })
        end)
        return "<C-c>" -- <Esc> would run the command when sent from a mapping
    end
    return "<CR>"
end, { expr = true, desc = "Run command, or show keymaps on :?" })

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

-- Experimental 0.12 message/cmdline UI: messages in floats, no "Press ENTER" prompts
-- cmdheight 0: the command line only shows while you type, messages fade after the timeout
require("vim._core.ui2").enable({ msg = { targets = "msg", msg = { timeout = 4000 } } })
vim.opt.cmdheight = 0

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
