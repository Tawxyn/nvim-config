local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local output = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({ { "Failed to install lazy.nvim:\n" .. output, "ErrorMsg" } }, true, {})
        return
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { import = "plugins" },
}, {
    defaults = { lazy = true, version = "*" },
    install = { colorscheme = { "mush-dark" } },
    checker = { enabled = false },
    change_detection = { notify = false },
})
