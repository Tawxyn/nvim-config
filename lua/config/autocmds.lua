local function group(name)
    return vim.api.nvim_create_augroup("config-" .. name, { clear = true })
end
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group("yank"),
    callback = function()
        vim.hl.on_yank()
    end,
})
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
    group = group("reload"),
    callback = function()
        if vim.fn.mode() == "n" and vim.fn.getcmdwintype() == "" then
            vim.cmd.checktime()
        end
    end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = group("reload-notify"),
    callback = function()
        vim.notify("Reloaded file changed outside Neovim")
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    group = group("rust-folds"),
    pattern = "rust",
    callback = function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
        vim.opt_local.foldlevel = 99
    end,
})
