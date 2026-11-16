return {
    {
        "Tawxyn/mush.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("mush").setup()
            vim.cmd.colorscheme("mush-dark")
        end,
    },
    {
        "nvim-mini/mini.nvim",
        event = "VeryLazy",
        config = function()
            require("mini.ai").setup({
                n_lines = 500,
                -- Leave Neovim 0.12's incremental selection mappings available.
                mappings = { around_next = "aa", inside_next = "ii" },
            })
            require("mini.surround").setup()
            require("mini.pairs").setup()
            require("mini.statusline").setup({ use_icons = vim.g.have_nerd_font })
        end,
    },
    {
        "NMAC427/guess-indent.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("guess-indent").setup({})
        end,
    },
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = false },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            delay = 300,
            icons = { mappings = vim.g.have_nerd_font },
            spec = {
                { "<leader>s", group = "Search" },
                { "<leader>t", group = "Toggle / terminal" },
                { "<leader>h", group = "Git hunks", mode = { "n", "x" } },
                { "<leader>d", group = "Debug / diagnostics" },
                { "gr", group = "LSP" },
            },
        },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        version = "v3.x",
        cmd = { "Neotree" },
        keys = { { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file explorer" } },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        init = function()
            -- Optional local DBL plugin. Missing checkouts never break startup.
            local lexdbl = require("config.platform").lexdbl()
            if vim.fn.isdirectory(lexdbl) == 1 then
                vim.opt.runtimepath:append(lexdbl)
                -- Load filetype detection from this local runtime too.
                for _, script in ipairs(vim.fn.globpath(lexdbl, "ftdetect/*", false, true)) do
                    if script:match("%.vim$") or script:match("%.lua$") then
                        vim.cmd.source({ script, magic = { file = false } })
                    end
                end
            end
        end,
        opts = {
            default_component_configs = {
                icon = vim.g.have_nerd_font and {} or {
                    folder_closed = "+",
                    folder_open = "-",
                    folder_empty = "+",
                    folder_empty_open = "-",
                    default = ".",
                    provider = function() end,
                },
                indent = { expander_collapsed = ">", expander_expanded = "v" },
            },
            filesystem = {
                follow_current_file = { enabled = true },
                filtered_items = { hide_dotfiles = false, hide_gitignored = false, hide_hidden = false },
            },
        },
    },
}
