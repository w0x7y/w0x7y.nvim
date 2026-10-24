-- No picker plugin: fuzzy : commands, :find via fd, :grep via rg, netrw sidebar

-- Folders that :find and :grep skip, on top of gitignored files
local ignore = { "node_modules", "bin", "obj" }

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
local fd = { "fd", "--type", "f" }
for _, dir in ipairs(ignore) do
	vim.list_extend(fd, { "-E", dir })
end
local files
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		files = nil -- list files once per command line, not on every keystroke
	end,
})
function _G.Find(arg)
	files = files or vim.fn.systemlist(fd)
	return arg == "" and files or vim.fn.matchfuzzy(files, arg)
end
vim.opt.findfunc = "v:lua.Find"

-- :grep fills the quickfix list and opens it, one line per match up to 10 lines
vim.opt.grepprg = "rg --line-number --column --no-heading --smart-case --glob=!"
	.. table.concat(ignore, " --glob=!") -- one entry per matching line
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

-- Keys
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":silent grep ", { desc = "Grep" }) -- silent: don't print rg's raw output over the editor
vim.keymap.set("n", "<leader>fb", ":buffer ", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fk", "<cmd>map<CR>", { desc = "List keymaps" })
vim.keymap.set("n", "<leader>fd", vim.diagnostic.setqflist, { desc = "List diagnostics" })
vim.keymap.set("n", "<leader>e", "<cmd>Lexplore<CR>", { desc = "Toggle file explorer sidebar (netrw)" })

-- netrw as a tree sidebar
vim.g.netrw_banner = 0 -- no help header; I shows it again
vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_winsize = -30 -- negative: sidebar width in columns, not percent
vim.g.Netrw_funcref = function() -- runs after netrw opens a file
	if vim.t.netrw_lexbufnr then
		vim.cmd("Lexplore") -- picked from the sidebar: close it
	end
end
