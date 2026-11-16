return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "-" },
                topdelete = { text = "-" },
                changedelete = { text = "~" },
            },
            signs_staged = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "-" },
                topdelete = { text = "-" },
                changedelete = { text = "~" },
            },
            signs_staged_enable = true,
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local function map(key, action, desc, mode)
                    vim.keymap.set(mode or "n", key, action, { buffer = bufnr, desc = "Git: " .. desc })
                end
                local function next_hunk()
                    gs.nav_hunk("next", { target = "all" })
                end
                local function prev_hunk()
                    gs.nav_hunk("prev", { target = "all" })
                end
                map("]h", next_hunk, "Next hunk")
                map("[h", prev_hunk, "Previous hunk")
                map("<leader>hn", next_hunk, "Next hunk")
                map("<leader>hm", prev_hunk, "Previous hunk")
                map("<leader>hs", gs.stage_hunk, "Stage hunk")
                map("<leader>hr", gs.reset_hunk, "Reset hunk")
                map("<leader>hu", gs.undo_stage_hunk, "Undo stage")
                map("<leader>hp", gs.preview_hunk, "Preview hunk")
                map("<leader>hd", gs.diffthis, "Diff buffer")
                map("<leader>hb", function()
                    gs.blame_line({ full = true })
                end, "Blame line")
                for key, action in pairs({ ["<leader>hs"] = gs.stage_hunk, ["<leader>hr"] = gs.reset_hunk }) do
                    map(key, function()
                        action({ vim.fn.line("."), vim.fn.line("v") })
                    end, "Selected hunk", "x")
                end
            end,
        },
    },
}
