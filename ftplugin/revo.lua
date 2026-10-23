vim.bo.commentstring = "# %s"
vim.bo.comments = ":#"
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true
-- LSP remains usable while the parser is being installed or rebuilt.
local ok, err = pcall(vim.treesitter.start, 0, "revo")
if not ok then
	vim.notify("Revo highlighting unavailable: " .. tostring(err), vim.log.levels.WARN)
end
