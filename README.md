# Neovim

My development setup, based on [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), with Rust tooling and a small, quiet UI. Shared between macOS and Windows.

Requires **Neovim 0.12+**. This uses the widely adopted [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager.

## Setup

Install the following and make them available on `PATH` before launching:

- [Neovim 0.12+](https://github.com/neovim/neovim/releases/latest) and Git.
- `ripgrep` (`rg`) for project search. `fd` is optional for file finding.
- `tree-sitter` CLI **0.26.1+**, a C compiler, `curl`, and `tar` for Treesitter parsers. On Mac: [`brew install tree-sitter-cli`](https://formulae.brew.sh/formula/tree-sitter-cli). Install the CLI through your package manager, not npm.
- `make` or CMake is optional for Telescope's native sorter. Without either, the standard sorter works.
- For Rust: `rustup component add rust-analyzer rustfmt`. A working Cargo toolchain is needed for builds, checks, and debugging.
- A Nerd Font is optional. Enable `vim.g.have_nerd_font` in `init.lua` if using one.

On Windows, run Neovim from an environment where the compiler is available, such as a Visual Studio Developer PowerShell or a MinGW environment. Neovim uses your normal shell; no PowerShell shim or PATH rewriting is needed.

The config lives at `~/.config/nvim` on Mac and `$env:LOCALAPPDATA\nvim` on Windows. If Windows keeps it somewhere else, point Neovim at this directory with your existing setup.

On this Mac, Homebrew installed Neovim at `/opt/homebrew/bin/nvim`. If `nvim --version` still reports 0.11, put Homebrew first on PATH with `export PATH="/opt/homebrew/bin:$PATH"` (and persist that in your shell setup). You can also launch `/opt/homebrew/bin/nvim` directly.

After upgrading Neovim, run `nvim`. lazy.nvim bootstraps itself and installs the configured plugins. Mason installs Lua's language server, StyLua, Taplo, and CodeLLDB. It also installs rust-analyzer if the active rustup toolchain has no component. Treesitter installs the configured parsers when the CLI is available. Keep Neovim open while those installations finish, then restart.

Check `:checkhealth workstation`, `:Mason`, and `:checkhealth vim.lsp nvim-treesitter rustaceanvim` for setup issues. `:TSInstallConfigured` retries the configured parser installation.

## Layout

- `init.lua`: version check and explicit module order.
- `lua/config/`: options, base mappings, autocmds, platform helpers, package build hooks.
- `lua/plugins/editor.lua`: theme, editing helpers, statusline, explorer, key hints.
- `lua/plugins/search.lua` and `git.lua`: Telescope and Git workflows.
- `lua/plugins/lsp.lua`: completion, language servers, Mason tools, LSP mappings.
- `lua/plugins/format.lua`: formatters and format-on-save policy.
- `lua/plugins/rust.lua`, `debug.lua`, `treesitter.lua`: language-specific development tools.

To add a plugin, return its lazy.nvim spec from the relevant module in `lua/plugins/`, keeping its setup there. To add a language server, enable an entry in the `servers` table in `lua/plugins/lsp.lua`. That list controls both installation and activation. Rust belongs to rustaceanvim; do not enable a second rust-analyzer through that table.

For the optional local Synergy DBL plugin, use `~/dev/lexdbl`, or set `NVIM_LEXDBL` to its checkout directory on either OS. A missing checkout is skipped.

## Keys

Leader is Space. Existing search, Git, explorer, formatting, and debugger bindings are largely preserved.

| Keys | Action |
| --- | --- |
| `<leader>e` | Toggle file explorer |
| `<leader>sf`, `<leader>sg`, `<leader>sw` | Find files, grep project, search word |
| `<leader><leader>`, `<leader>s.` | Buffers, recent files |
| `<leader>sh`, `<leader>sk`, `<leader>sn` | Help, keymaps, config files |
| `<leader>/`, `<leader>s/` | Search buffer, grep open files |
| `grd`, `grr`, `gri`, `grt` | Definition, references, implementations, type |
| `grn`, `gra`, `K`, `gK` | Rename, code action, hover, signature |
| `gO`, `gW` | Document and workspace symbols |
| `[d`, `]d`, `<leader>ds`, `<leader>q` | Navigate diagnostics, float, toggle buffer diagnostic list |
| `<leader>sd` | Search all diagnostics |
| `<leader>th` | Toggle inlay hints in this buffer |
| `<leader>f`, `<leader>tf` | Format buffer/selection, toggle buffer format-on-save |
| `[h`, `]h`, `<leader>hn`, `<leader>hm` | Navigate staged and unstaged Git hunks |
| `<leader>hs`, `<leader>hr`, `<leader>hu` | Stage, reset, undo staging a hunk |
| `<leader>hp`, `<leader>hd`, `<leader>hb` | Preview hunk, diff buffer, blame line |
| `<leader>tv`, `<Esc><Esc>` | Vertical terminal, leave terminal mode |
| `<F5>`, `<F8>`, `<F9>`, `<F10>` | Continue, step out, over, into |
| `<leader>db`, `<leader>dB`, `<leader>dl` | Breakpoint, conditional breakpoint, logpoint |
| `<leader>dc`, `<leader>dn`, `<leader>di`, `<leader>do` | Continue, step over, into, out |
| `<leader>dv`, `<leader>df`, `<leader>dr` | Debug view, focus scopes, REPL |
| `<leader>dh`, `<leader>dw`, `<leader>dL` | Hover variable, add watch, repeat run |
| `<leader>dt` | **Terminate** the debug session and close the view |
| `<leader>dd`, `<leader>dD` (Rust) | Pick a debuggable, debug target under cursor |
| `<leader>rr`, `<leader>rt`, `<leader>re` (Rust) | Runnables, testables, explain error |

Completion retains Tab to accept, Ctrl-Space to open, and Ctrl-N/P to navigate. LSP snippets use Neovim's built-in snippet engine. Only Lua, Rust, and TOML autoformat on save; other languages format explicitly with `<leader>f` when a formatter or LSP is available.

## Plugins and migration

- lazy.nvim follows stable plugin releases when available; explicit major constraints remain for Blink, Rustaceanvim, DAP View, and Neo-tree. `nvim-dap` tracks current `master` because DAP View 1.x requires its session-listener API. `nvim-treesitter` stays on `main` because this config uses its current Neovim 0.12 API.
- `lazy-lock.json` is generated by lazy.nvim and pins the tested plugin revisions. Keep it in version control so both machines match; run `:Lazy update` when reviewing newer releases.
- Existing Mason tools are reused. Modern parsers install in `data/treesitter`; legacy `data/site` parsers and queries are excluded from the runtime to avoid 0.11/0.12 incompatibilities. Old native package checkouts are no longer loaded. No plugin cache, undo history, or user data is deleted by this refactor.
- `mini.statusline` replaces Lualine and Navic. Trouble is replaced by Telescope diagnostics and native location lists. LuaSnip, markdown-preview, and the old native package lockfile are removed from the active config. Use your normal Markdown viewer; a preview plugin can be added later if needed.
- The custom rust-analyzer status handler was duplicating rustaceanvim's built-in handler. Using the built-in handler also restores its initialization hooks for debugger configurations.
- Debugging now uses public plugin APIs. `<leader>dt` terminates, rather than resuming a program and manually clearing its session state.
