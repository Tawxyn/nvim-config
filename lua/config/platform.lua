local M = {}

-- Resolve rustup's component, not its proxy (which can exist without a component).
function M.rust_analyzer()
    if vim.fn.executable("rustup") == 1 then
        local result = vim.system({ "rustup", "which", "rust-analyzer" }, { text = true }):wait()
        local path = vim.trim(result.stdout or "")
        if result.code == 0 and vim.fn.executable(path) == 1 then
            return path
        end
    end
end

function M.lexdbl()
    if vim.env.NVIM_LEXDBL and vim.env.NVIM_LEXDBL ~= "" then
        return vim.fs.normalize(vim.env.NVIM_LEXDBL)
    end
    -- No machine-specific username in the shared config.
    return vim.fs.joinpath(vim.fn.expand("~"), "dev", "lexdbl")
end

return M
