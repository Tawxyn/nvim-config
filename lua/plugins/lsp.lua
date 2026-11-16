local servers = {
    lua_ls = {
        settings = { Lua = { completion = { callSnippet = "Replace" }, format = { enable = false } } },
    },
    -- clangd = {},
    -- pyright = {},
    -- gopls = {},
}

return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "folke/lazydev.nvim",
            "neovim/nvim-lspconfig",
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "j-hui/fidget.nvim",
            "nvim-telescope/telescope.nvim",
        },
        opts = {
            keymap = { preset = "super-tab" },
            completion = { documentation = { auto_show = true, auto_show_delay_ms = 200 } },
            sources = {
                default = { "lsp", "path", "snippets", "buffer", "lazydev" },
                providers = { lazydev = { module = "lazydev.integrations.blink", score_offset = 100 } },
            },
            -- Neovim's snippet engine handles LSP snippets without LuaSnip.
            snippets = { preset = "default" },
            fuzzy = { implementation = "lua" },
            signature = { enabled = true },
        },
        config = function(_, opts)
            require("lazydev").setup({ library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } })
            require("blink.cmp").setup(opts)
            require("fidget").setup({})
            require("mason").setup({})
            require("mason-lspconfig").setup({ automatic_enable = false })

            -- Only explicitly configured servers start; rustaceanvim owns Rust.
            vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
            for name, settings in pairs(servers) do
                vim.lsp.config(name, settings)
                vim.lsp.enable(name)
            end
            local tools = vim.tbl_keys(servers)
            vim.list_extend(tools, { "stylua", "taplo", "codelldb" })
            if not require("config.platform").rust_analyzer() then
                tools[#tools + 1] = "rust-analyzer"
            end
            require("mason-tool-installer").setup({ ensure_installed = tools, start_delay = 1000 })

            local attach = vim.api.nvim_create_augroup("config-lsp-attach", { clear = true })
            local highlights = vim.api.nvim_create_augroup("config-lsp-highlights", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = attach,
                callback = function(event)
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if not client then
                        return
                    end
                    local function map(key, action, desc, mode)
                        vim.keymap.set(mode or "n", key, action, { buffer = event.buf, desc = "LSP: " .. desc })
                    end
                    local b = require("telescope.builtin")
                    for key, action in pairs({
                        grr = b.lsp_references,
                        gri = b.lsp_implementations,
                        grd = b.lsp_definitions,
                        grt = b.lsp_type_definitions,
                        gO = b.lsp_document_symbols,
                        gW = b.lsp_dynamic_workspace_symbols,
                    }) do
                        map(key, action, "Search " .. key)
                    end
                    map("grn", vim.lsp.buf.rename, "Rename")
                    map("gra", vim.lsp.buf.code_action, "Code action", { "n", "x" })
                    map("grD", vim.lsp.buf.declaration, "Declaration")
                    map("K", function()
                        vim.lsp.buf.hover({ max_width = 90, max_height = 30 })
                    end, "Hover")
                    map("gK", function()
                        vim.lsp.buf.signature_help({ max_width = 90, max_height = 30 })
                    end, "Signature")
                    if client:supports_method("textDocument/inlayHint", event.buf) then
                        map("<leader>th", function()
                            vim.lsp.inlay_hint.enable(
                                not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
                                { bufnr = event.buf }
                            )
                        end, "Toggle inlay hints")
                    end
                    if client:supports_method("textDocument/documentHighlight", event.buf) then
                        -- One set per buffer, even with multiple LSP clients.
                        vim.api.nvim_clear_autocmds({ group = highlights, buffer = event.buf })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            group = highlights,
                            buffer = event.buf,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            group = highlights,
                            buffer = event.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end
                end,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
                group = attach,
                callback = function(event)
                    -- Detaching one client must not remove highlighting for another.
                    for _, client in ipairs(vim.lsp.get_clients({ bufnr = event.buf })) do
                        if
                            client.id ~= event.data.client_id
                            and client:supports_method("textDocument/documentHighlight", event.buf)
                        then
                            return
                        end
                    end
                    vim.lsp.util.buf_clear_references(event.buf)
                    vim.api.nvim_clear_autocmds({ group = highlights, buffer = event.buf })
                end,
            })
        end,
    },
}
