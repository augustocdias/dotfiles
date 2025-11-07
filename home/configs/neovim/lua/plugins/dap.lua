-- debug adapters. I probably want to remove this
return 
{
    {
        'nvim-dap-virtual-text', -- virtual text during debugging
        dep_of = 'nvim-dap'
    },
    {
        'nvim-dap-ui',            -- ui for nvim-dap
        dep_of = 'nvim-dap'
    },
    {
        'nvim-nio',
        dep_of = 'nvim-dap'
    },
    {
    'nvim-dap', -- debug adapter for debugging
    enabled = false,
    event = 'DeferredUIEnter',
    after = function()
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
    keys = {
        {
            '<F4>',
            function()
                require('dap').repl.toggle()
            end,
            mode = { 'n' },
            desc = 'DAP Toggle repl',
            silent = true,
        },
        {
            '<F5>',
            function()
                require('dap').continue()
            end,
            mode = { 'n' },
            desc = 'DAP Continue',
            silent = true,
        },
        {
            '<S-F5>',
            function()
                require('dap').close()
            end,
            mode = { 'n' },
            desc = 'DAP Stop',
            silent = true,
        },
        {
            '<C-F5>',
            function()
                require('dap').run_last()
            end,
            mode = { 'n' },
            desc = 'DAP Run last',
            silent = true,
        },
        {
            '<F6>',
            function()
                require('dap').pause()
            end,
            mode = { 'n' },
            desc = 'DAP Pause',
            silent = true,
        },
        {
            '<F9>',
            function()
                require('dap').toggle_breakpoint()
            end,
            mode = { 'n' },
            desc = 'DAP Toggle breakpoint',
            silent = true,
        },
        {
            '<S-F9>',
            function()
                require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end,
            mode = { 'n' },
            desc = 'DAP Set breakpoint with condition',
            silent = true,
        },
        {
            '<C-F9>',
            function()
                require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
            end,
            mode = { 'n' },
            desc = 'DAP Set logpoint',
            silent = true,
        },
        {
            '<F10>',
            function()
                require('dap').step_over()
            end,
            mode = { 'n' },
            desc = 'DAP Step over',
            silent = true,
        },
        {
            '<S-F10>',
            function()
                require('dap').run_to_cursor()
            end,
            mode = { 'n' },
            desc = 'DAP Run to cursor',
            silent = true,
        },
        {
            '<F11>',
            function()
                require('dap').step_into()
            end,
            mode = { 'n' },
            desc = 'DAP Step into',
            silent = true,
        },
        {
            '<S-F11>',
            function()
                require('dap').step_out()
            end,
            mode = { 'n' },
            desc = 'DAP Step out',
            silent = true,
        },
        {
            '<F7>',
            function()
                require('dap.ui.widgets').hover()
            end,
            mode = { 'x' },
            desc = 'DAP Hover',
            silent = true,
        },
    },
}}
