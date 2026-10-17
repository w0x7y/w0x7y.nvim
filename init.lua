-- Leader key
vim.g.mapleader = " "

-- Key Binds
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<C-x>", '"+d', { desc = "Cut to system clipboard" })

vim.keymap.set("n", "<leader>t", function()
    Snacks.terminal.toggle()
end, { desc = "Toggle Terminal" })

vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
end, { desc = "Toggle inline diagnostics" })

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

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"

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
