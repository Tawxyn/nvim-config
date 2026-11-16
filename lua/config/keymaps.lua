local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    map("n", "<C-" .. key .. ">", "<C-w>" .. key, { desc = "Window " .. direction })
end
map("n", "<leader>tv", "<cmd>vertical terminal<CR>", { desc = "Terminal (vertical)" })
map("n", "<leader>q", function()
    -- A location list belongs to one editing window, rather than every window.
    if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        vim.cmd.lclose()
    else
        vim.diagnostic.setloclist({ open = true })
    end
end, { desc = "Toggle buffer diagnostics list" })
map("n", "<leader>ds", vim.diagnostic.open_float, { desc = "Show diagnostic" })
