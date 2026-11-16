return {
    {
        "igorlfs/nvim-dap-view",
        version = "1.*",
        event = "VeryLazy",
        -- dap-view 1.x requires nvim-dap's current session listener API.
        dependencies = { { "mfussenegger/nvim-dap", version = false } },
        config = function()
            local dap = require("dap")
            local view = require("dap-view")
            view.setup({
                windows = { position = "below", size = 0.25 },
                auto_toggle = false,
                virtual_text = { enabled = true },
                icons = vim.g.have_nerd_font and {} or {
                    collapsed = ">",
                    expanded = "v",
                    disabled = "x",
                    enabled = "ok",
                    negate = "not",
                    pause = "pause",
                    play = "run",
                    step_back = "back",
                    step_into = "into",
                    step_out = "out",
                    step_over = "next",
                    terminate = "stop",
                    disconnect = "disconnect",
                    run_last = "last",
                    filter = "filter",
                },
            })
            -- Keep output visible after exit. No changes to DAP session internals.
            dap.listeners.after.event_initialized["config-view"] = function()
                view.open()
            end
            dap.listeners.after.event_exited["config-exit"] = function(_, body)
                vim.notify("Debug session exited (code " .. tostring(body and body.exitCode or "unknown") .. ")")
            end
            for name, text in pairs({
                DapBreakpoint = "B",
                DapBreakpointCondition = "C",
                DapLogPoint = "L",
                DapStopped = "=>",
                DapBreakpointRejected = "X",
            }) do
                vim.fn.sign_define(
                    name,
                    { text = text, texthl = name == "DapStopped" and "DiagnosticInfo" or "DiagnosticError" }
                )
            end
            local actions = {
                ["<F5>"] = { dap.continue, "Continue / start" },
                ["<F8>"] = { dap.step_out, "Step out" },
                ["<F9>"] = { dap.step_over, "Step over" },
                ["<F10>"] = { dap.step_into, "Step into" },
                ["<leader>dc"] = { dap.continue, "Continue / start" },
                ["<leader>db"] = { dap.toggle_breakpoint, "Toggle breakpoint" },
                ["<leader>dn"] = { dap.step_over, "Step over" },
                ["<leader>di"] = { dap.step_into, "Step into" },
                ["<leader>do"] = { dap.step_out, "Step out" },
                ["<leader>dB"] = {
                    function()
                        dap.set_breakpoint(vim.fn.input("Condition: "))
                    end,
                    "Conditional breakpoint",
                },
                ["<leader>dl"] = {
                    function()
                        dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
                    end,
                    "Logpoint",
                },
                ["<leader>dr"] = { dap.repl.toggle, "Toggle REPL" },
                ["<leader>dL"] = { dap.run_last, "Run last" },
                ["<leader>dv"] = { view.toggle, "Toggle debug view" },
                ["<leader>df"] = {
                    function()
                        view.open()
                        view.jump_to_view("scopes")
                    end,
                    "Focus debug scopes",
                },
                ["<leader>dt"] = {
                    function()
                        dap.terminate()
                        view.close(true)
                    end,
                    "Terminate debug session",
                },
            }
            for key, action in pairs(actions) do
                vim.keymap.set("n", key, action[1], { desc = "Debug: " .. action[2] })
            end
            vim.keymap.set({ "n", "x" }, "<leader>dh", function()
                view.hover()
            end, { desc = "Debug: Hover variable" })
            vim.keymap.set({ "n", "x" }, "<leader>dw", function()
                view.add_expr()
            end, { desc = "Debug: Add watch" })
        end,
    },
}
