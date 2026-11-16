-- A personal, modular Kickstart setup. See README.md for requirements and keys.
if vim.fn.has("nvim-0.12") == 0 then
    vim.api.nvim_echo(
        { { "This config requires Neovim 0.12+. See README.md for migration steps.", "ErrorMsg" } },
        true,
        {}
    )
    return
end

vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
