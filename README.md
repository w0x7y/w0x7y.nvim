# nvim, w0x7y special

my neovim config. one `init.lua`, one plugin file, [rime](https://github.com/w0x7y/rime) colors and [revo](https://github.com/if-not-nil/revo) support

<p align="center">
<img width="49%" alt="the rime snowflake dashboard" src="1.png" />
<img width="49%" alt="editing lua in rime" src="2.png" />
</p>

<p align="center">
<a href="#install">install</a> |
<a href="#keys">keys</a> |
<a href="#whats-in-it">what's in it</a> |
<a href="#revo">revo</a> |
<a href="#layout">layout</a>
</p>

### install

needs neovim `0.12`+, git and a nerd font

```sh
git clone https://github.com/w0x7y/w0x7y.nvim ~/.config/nvim
nvim
```

lazy.nvim installs itself and every plugin on first start\
mason then installs the language servers and formatters

<details>
<summary>~ other programs it calls</summary>

<br>

| program | for |
|---|---|
| `fd` | `<leader>ff` |
| `rg` | `<leader>fg` |
| `tree-sitter` cli and a c compiler | building parsers |
| `revo` | the revo lsp, from `$PATH` or `~/.local/bin/revo` |
| a python venv in `~/.local/share/better-sql-venv` | better-sql.nvim |
| kitty, wezterm or ghostty | showing images |
| `magick` | images that aren't png |

</details>

### keys

leader is `<space>`

| key | does |
|---|---|
| `<leader>ff` | find files, `:find` with a fuzzy menu |
| `<leader>fg` | grep the project into the quickfix list |
| `<leader>fb` | buffers, `:buffer` with a fuzzy menu |
| `<leader>fk` | list every keymap |
| `<leader>fd` | every diagnostic, in the quickfix list |
| `<leader>e` | file explorer (netrw) |
| `<leader>jf` | format the file or selection |
| `s` | flash jump |
| `S` | flash select a treesitter node |
| `gd` | go to definition |

the other lsp keys are neovim's own: `grr` references, `grn` rename, `gra` code action, `gri` implementation, `gO` symbols, `K` hover

in completion, `<Tab>` and `<S-Tab>` move through items and snippet fields\
`<CR>` only confirms an item you picked, `<C-space>` shows its docs\
snippets stay out of the menu. type `@` before a word, like `@for`, to list only snippets. the `@` goes away when one expands

### what's in it

~ [rime](https://github.com/w0x7y/rime) colorscheme, switch variants in `lua/plugins/rime.lua`\
~ snacks.nvim for the dashboard, images, indent guides and highlighting other uses of the word under the cursor\
~ image files open as the picture, and markdown images show inline at up to 40x15 cells\
~ no picker plugin. `:` commands get a fuzzy menu as you type, and `:find` lists files with `fd`\
~ `<leader>fg` runs `rg` and opens the matches in a quickfix window that fits them, up to 10 lines. `]q` and `[q` step through\
~ git and diagnostic signs replace the line number instead of taking their own column\
~ blink.cmp with its own snippet engine and friendly-snippets\
~ mason installs clangd, omnisharp, lua_ls, pyright, rust_analyzer, html, cssls, ts_ls, eslint and jsonls\
~ conform formats on save with stylua, csharpier, clang-format, black, rustfmt and prettier, all at 4 spaces\
~ diagnostics show in full under the cursor's line and nowhere else\
~ neovim 0.12's new message ui, so no "press ENTER" prompts\
~ lualine shows `recording @q` while a macro records\
~ treesitter, lualine, gitsigns, autopairs, ts-autotag, render-markdown, lazydev\
~ [better-sql.nvim](https://github.com/w0x7y/better-sql.nvim) with a `supabase` connection read from `~/.pg_service.conf`

### revo

`lua/revo.lua` and `ftplugin/revo.lua` set up [revo](https://github.com/if-not-nil/revo) by hand

~ `.rv`, `.revo` and files with a revo shebang get the `revo` filetype\
~ `revo lsp` runs as the language server, with inlay hints on\
~ the parser builds from `~/.local/share/revo/tree-sitter-revo-current`\
~ [revofmt.nvim](https://github.com/w0x7y/revofmt.nvim) formats on save\
~ 43 snippets in `snippets/revo.json`, like `fn`, `match`, `test`, `class` and `cli`

> [!TIP]
> set `vim.g.revo_executable` or `vim.g.revo_grammar_path` before `require("revo")` to use another binary or grammar

### layout

```text
init.lua              options, keymaps, lazy bootstrap
lua/plugins/init.lua  every plugin except the colorscheme
lua/plugins/rime.lua  colorscheme
lua/revo.lua          revo filetype, lsp and parser
ftplugin/revo.lua     revo indent, comments and highlighting
snippets/             revo snippets, loaded by blink.cmp
```

_license: [mit](./LICENSE)_
