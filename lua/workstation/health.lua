local M = {}

function M.check()
    local health = vim.health
    health.start("Personal Kickstart configuration")
    if vim.fn.has("nvim-0.12") == 1 then
        health.ok("Neovim 0.12+")
    else
        health.error("Neovim 0.12+ is required. Update the executable on PATH.")
    end
    for _, command in ipairs({ "git", "rg", "tree-sitter" }) do
        if vim.fn.executable(command) == 1 then
            health.ok(command .. ": " .. vim.fn.exepath(command))
        else
            health.error("Missing " .. command .. ". See README.md requirements.")
        end
    end
    if vim.fn.executable("tree-sitter") == 1 then
        local result = vim.system({ "tree-sitter", "--version" }, { text = true }):wait()
        local version = (result.stdout or ""):match("%d+%.%d+%.%d+")
        if result.code ~= 0 or not version or vim.version.lt(version, "0.26.1") then
            health.error("Treesitter's main branch requires tree-sitter CLI 0.26.1+.")
        end
    end
    local compiler = false
    for _, command in ipairs({ "cc", "gcc", "clang", "cl" }) do
        compiler = compiler or vim.fn.executable(command) == 1
    end
    if compiler then
        health.ok("C compiler found")
    else
        health.error("A C compiler is needed for parsers.")
    end
    if vim.fn.executable("make") == 0 and vim.fn.executable("cmake") == 0 then
        health.warn("make/cmake unavailable: Telescope uses its Lua sorter.")
    end
    if require("config.platform").rust_analyzer() then
        health.ok("rust-analyzer provided by the active rustup toolchain")
    else
        health.info(
            "Using Mason's rust-analyzer fallback. Prefer: rustup component add rust-analyzer rustfmt"
        )
    end
    if vim.fn.executable("rustfmt") == 0 then
        health.warn("rustfmt is unavailable.")
    end
    health.info("Run :checkhealth vim.lsp nvim-treesitter rustaceanvim for plugin details.")
end

return M
