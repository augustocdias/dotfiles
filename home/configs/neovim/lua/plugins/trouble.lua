-- adds a bottom panel with lsp diagnostics, quickfixes, etc.

return {
    'trouble',
    cmd = 'Trouble',
    after = function() require('trouble').setup({
        modes = {
            diagnostics = {
                filter = {
                    any = {
                        function(item)
                            return item.filename:find((vim.loop or vim.uv).cwd(), 1, true)
                        end,
                    },
                },
            },
        },
    })end,
    keys = {
        {
            '<M-t>',
            ':Trouble diagnostics toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Show diagnostics pane',
            noremap = true,
            silent = true,
        },
        { -- TEST: require('dap').list_breakpoints() adds them to a qflist
            '<leader>tb',
            function()
                require('dap').list_breakpoints()
                require('trouble').toggle({ mode = 'qflist', focus = true })
            end,
            mode = { 'n' },
            desc = 'Breakpoints',
            noremap = true,
        },
        {
            '<leader>tc',
            ':Trouble lsp_declarations toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'LSP Declarations',
            noremap = true,
        },
        {
            '<leader>td',
            ':Trouble diagnostics toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Show diagnostics pane',
            noremap = true,
            silent = true,
        },
        {
            '<leader>tf',
            ':Trouble lsp_definitions toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'LSP Definitions',
            noremap = true,
        },
        {
            '<leader>ti',
            ':Trouble lsp_implementations toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'LSP Implementations',
            noremap = true,
        },
        {
            '<leader>tl',
            ':Trouble todo toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Toggle todo list',
            noremap = true,
        },
        {
            '<leader>to',
            ':Trouble loclist toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Location List',
            noremap = true,
        },
        {
            '<leader>tq',
            ':Trouble qflist toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'Quickfix List',
            noremap = true,
        },
        {
            '<leader>tr',
            ':Trouble lsp_references toggle focus=true<CR>',
            mode = { 'n' },
            desc = 'LSP References',
            noremap = true,
        },
        {
            '<leader>ts',
            ':Trouble symbols toggle pinned=true win.relative=win win.position=right focus=true<CR>',
            mode = { 'n' },
            desc = 'Symbols',
            noremap = true,
        },
    },
}
