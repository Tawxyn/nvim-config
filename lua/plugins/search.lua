local function run(command, cwd)
    local result = vim.system(command, { cwd = cwd, text = true }):wait()
    if result.code ~= 0 then
        error(table.concat(command, " ") .. " failed:\n" .. (result.stderr or result.stdout or ""))
    end
end

local function build_fzf(plugin)
    if vim.fn.executable("make") == 1 then
        run({ "make" }, plugin.dir)
    elseif vim.fn.executable("cmake") == 1 then
        run({ "cmake", "-S", ".", "-B", "build", "-DCMAKE_BUILD_TYPE=Release" }, plugin.dir)
        run({ "cmake", "--build", "build", "--config", "Release", "--target", "install" }, plugin.dir)
    end
end

return {
    {
        "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                enabled = function()
                    return vim.fn.executable("make") == 1 or vim.fn.executable("cmake") == 1
                end,
                build = build_fzf,
            },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({ extensions = { ["ui-select"] = require("telescope.themes").get_dropdown() } })
            pcall(telescope.load_extension, "fzf")
            telescope.load_extension("ui-select")
            local builtin = require("telescope.builtin")
            local pickers = {
                sh = { "help_tags", "Help" },
                sk = { "keymaps", "Keymaps" },
                sf = { "find_files", "Files" },
                ss = { "builtin", "Pickers" },
                sw = { "grep_string", "Word" },
                sg = { "live_grep", "Grep" },
                sd = { "diagnostics", "Diagnostics" },
                sr = { "resume", "Resume" },
                ["s."] = { "oldfiles", "Recent files" },
                sc = { "commands", "Commands" },
                ["<leader>"] = { "buffers", "Buffers" },
            }
            for key, picker in pairs(pickers) do
                vim.keymap.set("n", "<leader>" .. key, builtin[picker[1]], { desc = "Search: " .. picker[2] })
            end
            vim.keymap.set("n", "<leader>/", function()
                builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ previewer = false }))
            end, { desc = "Search current buffer" })
            vim.keymap.set("n", "<leader>s/", function()
                builtin.live_grep({ grep_open_files = true, prompt_title = "Grep open files" })
            end, { desc = "Search open files" })
            vim.keymap.set("n", "<leader>sn", function()
                builtin.find_files({ cwd = vim.fn.stdpath("config") })
            end, { desc = "Search Neovim config" })
        end,
    },
}
