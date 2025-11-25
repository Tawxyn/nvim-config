vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

-- Options
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split"
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Tabs & indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

-- Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Win left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Win right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Win down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Win up" })

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"NMAC427/guess-indent.nvim",

	{ --git diff
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { hl = "GitSignsAdd", text = "+", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
				change = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
				delete = { hl = "GitSignsDelete", text = "-", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
				topdelete = {
					hl = "GitSignsDelete",
					text = "-",
					numhl = "GitSignsDeleteNr",
					linehl = "GitSignsDeleteLn",
				},
				changedelete = {
					hl = "GitSignsChange",
					text = "~",
					numhl = "GitSignsChangeNr",
					linehl = "GitSignsChangeLn",
				},
			},
			numhl = false,
			linehl = false,
			current_line_blame = false,
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local map = function(lhs, rhs, desc, mode)
					vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, desc = desc })
				end

				-- Full buffer diff
				map("<leader>hd", function()
					gs.diffthis()
				end, "Diff Buffer (Split)")

				-- Hunk preview (chunk diff)
				map("<leader>hp", function()
					gs.preview_hunk({ max_height = 15, border = "rounded" })
				end, "Preview Hunk (Chunk Diff)")
			end,
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)
			vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#98c379" })
			vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e5c07b" })
			vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#e06c75" })
		end,
	},
	{ -- which-key
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			delay = 0,
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<SWD> ",
					ScrollWheelUp = "<SWU> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},
			spec = {
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},

	{ -- Markdown preview
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

	{ -- Telescope
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			"nvim-telescope/telescope-ui-select.nvim",
			{
				"nvim-tree/nvim-web-devicons",
				lazy = true,
				config = function()
					require("nvim-web-devicons").setup({
						override = {},
						default = true,
					})
				end,
			},
		},
		config = function()
			require("telescope").setup({
				extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
			})
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			local b = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", b.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", b.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", b.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", b.builtin, { desc = "[S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", b.grep_string, { desc = "[S]earch [W]ord" })
			vim.keymap.set("n", "<leader>sg", b.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", b.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", b.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", b.oldfiles, { desc = "[S]earch Recent Files" })
			vim.keymap.set("n", "<leader><leader>", b.buffers, { desc = "Find buffers" })
			vim.keymap.set("n", "<leader>/", function()
				b.current_buffer_fuzzy_find(
					require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
				)
			end, { desc = "Fuzzy search buffer" })
			vim.keymap.set("n", "<leader>s/", function()
				b.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
			end, { desc = "Grep Open Files" })
			vim.keymap.set("n", "<leader>sn", function()
				b.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	{ -- LSP + tooling
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
				},
			},
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(ev)
					local map = function(keys, fn, desc, mode)
						vim.keymap.set(mode or "n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
					end
					map("grn", vim.lsp.buf.rename, "Rename")
					map("gra", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
					map("grr", require("telescope.builtin").lsp_references, "References")
					map("gri", require("telescope.builtin").lsp_implementations, "Implementation")
					map("grd", require("telescope.builtin").lsp_definitions, "Definition")
					map("grD", vim.lsp.buf.declaration, "Declaration")
					map("gO", require("telescope.builtin").lsp_document_symbols, "Document Symbols")
					map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace Symbols")
					map("grt", require("telescope.builtin").lsp_type_definitions, "Type Definition")

					local function supports(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end

					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client and supports(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, ev.buf) then
						local hl = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = ev.buf,
							group = hl,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = ev.buf,
							group = hl,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(e2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = e2.buf })
							end,
						})
					end

					if client and supports(client, vim.lsp.protocol.Methods.textDocument_inlayHint, ev.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
						end, "Toggle Inlay Hints")
					end
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(d)
						return d.message
					end,
				},
			})

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local servers = {
				lua_ls = { settings = { Lua = { completion = { callSnippet = "Replace" } } } },
			}

			local ensure = vim.tbl_keys(servers)
			vim.list_extend(ensure, { "stylua" })
			require("mason-tool-installer").setup({ ensure_installed = ensure })

			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_installation = false,
				handlers = {
					function(name)
						local cfg = servers[name] or {}
						cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
						require("lspconfig")[name].setup(cfg)
					end,
				},
			})
		end,
	},

	{ -- Format
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(buf)
				local disable = { c = true, cpp = true }
				if disable[vim.bo[buf].filetype] then
					return nil
				end
				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
			formatters_by_ft = { lua = { "stylua" } },
		},
	},

	{ -- Completion
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				opts = {},
			},
			"folke/lazydev.nvim",
		},
		opts = {
			keymap = { preset = "super-tab" },
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 100,
					window = {
						border = "rounded",
						max_width = 80,
						max_height = 30,
					},
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = { lazydev = { module = "lazydev.integrations.blink", score_offset = 100 } },
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.opt.background = "dark"
			vim.g.oxocarbon_lua_transparent = true -- optional
			vim.cmd("colorscheme oxocarbon")
		end,
	},

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- mini.nvim collection
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			require("mini.pairs").setup()
		end,
	},

	{ -- Status Line
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "auto",
				icons_enabled = true,
				globalstatus = true,
				section_separators = { left = "", right = "" },
				component_separators = { left = "│", right = "│" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_diagnostic" } } },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},

	{ -- Treesitter
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = { enable = true, additional_vim_regex_highlighting = { "ruby" } },
			indent = { enable = true, disable = { "ruby" } },
		},
	},

	{ -- Neo-tree
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
		opts = { filesystem = { follow_current_file = { enabled = true } } },
	},
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
