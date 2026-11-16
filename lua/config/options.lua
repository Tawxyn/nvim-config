-- Keep legacy 0.11 parsers/queries out of the runtime. Modern parsers get
-- their own directory below.
local legacy_site = vim.fs.joinpath(vim.fn.stdpath("data"), "site")
vim.opt.runtimepath:remove(legacy_site)
vim.opt.runtimepath:remove(vim.fs.joinpath(legacy_site, "after"))

local options = {
    termguicolors = true,
    number = true,
    relativenumber = true,
    mouse = "a",
    showmode = false,
    breakindent = true,
    undofile = true,
    ignorecase = true,
    smartcase = true,
    signcolumn = "yes",
    updatetime = 250,
    timeoutlen = 300,
    splitright = true,
    splitbelow = true,
    list = false,
    inccommand = "split",
    cursorline = true,
    scrolloff = 10,
    confirm = true,
    autoread = true,
    expandtab = true,
    tabstop = 4,
    shiftwidth = 4,
    softtabstop = 4,
    winborder = "rounded",
    laststatus = 3,
}
for name, value in pairs(options) do
    vim.o[name] = value
end
vim.opt.listchars = { tab = ">>", trail = ".", nbsp = "_" }
vim.opt.fillchars = { eob = " " }
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

-- Diagnostics stay quiet until requested or navigated to.
vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    virtual_text = false,
    virtual_lines = false,
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    float = { source = "if_many", max_width = 100 },
    signs = { text = { [1] = "E", [2] = "W", [3] = "I", [4] = "H" } },
    jump = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
        end,
    },
})
