return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local ts = require("nvim-treesitter")
            ts.setup({ install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "treesitter") })
            local parsers = {
                "bash",
                "c",
                "cpp",
                "diff",
                "html",
                "json",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "rust",
                "toml",
                "vim",
                "vimdoc",
                "yaml",
            }
            local group = vim.api.nvim_create_augroup("config-treesitter", { clear = true })
            local function attach(bufnr)
                if not vim.api.nvim_buf_is_valid(bufnr) then
                    return
                end
                local language = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
                if not language then
                    return
                end
                if not pcall(vim.treesitter.start, bufnr, language) then
                    return
                end
                -- Rust's built-in indent script works better for this setup.
                if language ~= "rust" and vim.treesitter.query.get(language, "indents") then
                    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end
            vim.api.nvim_create_autocmd("FileType", {
                group = group,
                callback = function(event)
                    attach(event.buf)
                end,
            })
            local function install()
                ts.install(parsers):await(function()
                    -- First-run installs complete after FileType: attach those buffers too.
                    vim.schedule(function()
                        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                            if vim.api.nvim_buf_is_loaded(bufnr) then
                                attach(bufnr)
                            end
                        end
                    end)
                end)
            end
            vim.api.nvim_create_user_command("TSInstallConfigured", install, { desc = "Install configured parsers" })
            if vim.fn.executable("tree-sitter") == 1 then
                install()
            end
        end,
    },
}
