-- Revo's CLI bundles Revolt. Requires Neovim 0.11+ and nvim-treesitter main.
vim.filetype.add({
	extension = { rv = "revo", revo = "revo" },
	pattern = {
		[".*"] = {
			function(_, bufnr)
				local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
				if first:match("^#!.*%f[%w]revo%f[%W]") then
					return "revo"
				end
			end,
			{ priority = -math.huge },
		},
	},
})

local executable = vim.g.revo_executable or vim.fn.exepath("revo")
if executable == "" then
	executable = vim.fn.expand("~/.local/bin/revo")
end
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
	capabilities = cmp.default_capabilities(capabilities)
end
vim.lsp.config("revo", {
	cmd = { executable, "lsp" },
	filetypes = { "revo" },
	root_markers = { "lib.json", "exe.json", ".git" },
	capabilities = capabilities,
})
vim.lsp.enable("revo")

-- The local checkout matches the public grammar revision in extension.toml.
local function register_parser()
	local ok, parsers = pcall(require, "nvim-treesitter.parsers")
	if ok then
		parsers.revo = {
			install_info = {
				path = vim.g.revo_grammar_path or vim.fn.expand("~/.local/share/revo/tree-sitter-revo-current"),
				queries = "queries",
			},
		}
	end
end

local group = vim.api.nvim_create_augroup("Revo", { clear = true })
vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "TSUpdate",
	callback = register_parser,
})
register_parser()
vim.treesitter.language.register("revo", "revo")

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "revo",
	callback = function(event)
		vim.bo[event.buf].commentstring = "# %s"
		vim.bo[event.buf].comments = ":#"
		vim.bo[event.buf].shiftwidth = 2
		vim.bo[event.buf].tabstop = 2
		vim.bo[event.buf].softtabstop = 2
		vim.bo[event.buf].expandtab = true
		-- LSP remains usable while the parser is being installed or rebuilt.
		local ok, err = pcall(vim.treesitter.start, event.buf, "revo")
		if not ok then
			vim.notify("Revo highlighting unavailable: " .. tostring(err), vim.log.levels.WARN)
		end
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
			buffer = event.buf,
			desc = "Go to definition",
		})
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.name == "revo" and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
		end
	end,
})
