return {
    setup = function()
        local dap, dapui = require('dap'), require('dapui')
        require('nvim-dap-virtual-text').setup({
            all_frames = true,
        })
        dapui.setup()
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
        vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
        vim.fn.sign_define(
            'DapBreakpointCondition',
            { text = '', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' }
        )
        vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DataLogPoint', linehl = '', numhl = '' })
        vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapSign', linehl = 'DapLineStopped', numhl = '' })
        vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapSign', linehl = '', numhl = '' })
    end,
}
