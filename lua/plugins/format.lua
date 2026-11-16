return {
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            notify_on_error = true,
            default_format_opts = { lsp_format = "fallback" },
            formatters_by_ft = { lua = { "stylua" }, rust = { "rustfmt" }, toml = { "taplo" } },
            formatters = {
                rustfmt = {
                    prepend_args = { "+stable" },
                },
            },
            -- Keep saves predictable: only the configured languages autoformat.
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                if vim.tbl_contains({ "lua", "rust", "toml" }, vim.bo[bufnr].filetype) then
                    return { timeout_ms = 1500, lsp_format = "fallback" }
                end
            end,
        },
        config = function(_, opts)
            require("conform").setup(opts)
            vim.keymap.set({ "n", "x" }, "<leader>f", function()
                require("conform").format({ async = true })
            end, { desc = "Format buffer / selection" })
            vim.keymap.set("n", "<leader>tf", function()
                vim.b.disable_autoformat = not vim.b.disable_autoformat
                vim.notify("Format on save: " .. (vim.b.disable_autoformat and "off" or "on"))
            end, { desc = "Toggle buffer format on save" })
        end,
    },
}
