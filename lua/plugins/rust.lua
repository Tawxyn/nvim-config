return {
    {
        "mrcjkb/rustaceanvim",
        version = "7.*",
        ft = "rust",
        dependencies = { "saghen/blink.cmp", "mfussenegger/nvim-dap" },
        init = function()
            vim.g.rustaceanvim = {
                server = {
                    cmd = function()
                        return { require("config.platform").rust_analyzer() or "rust-analyzer" }
                    end,
                    capabilities = require("blink.cmp").get_lsp_capabilities(),
                    status_notify_level = "error",
                    default_settings = {
                        ["rust-analyzer"] = {
                            cargo = { allFeatures = false, buildScripts = { enable = true } },
                            check = { command = "check" },
                            procMacro = { enable = true },
                        },
                    },
                },
                -- The plugin detects CodeLLDB through Mason/PATH on Mac and Windows.
                dap = { autoload_configurations = true },
            }
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("config-rust-keys", { clear = true }),
                pattern = "rust",
                callback = function(event)
                    for key, command in pairs({
                        dd = "debuggables",
                        dD = "debug",
                        rr = "runnables",
                        rt = "testables",
                        re = "explainError",
                    }) do
                        vim.keymap.set("n", "<leader>" .. key, "<cmd>RustLsp " .. command .. "<CR>", {
                            buffer = event.buf,
                            desc = "Rust: " .. command,
                        })
                    end
                end,
            })
        end,
    },
    {
        "saecki/crates.nvim",
        ft = "toml",
        opts = {},
    },
}
