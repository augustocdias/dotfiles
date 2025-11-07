-- show git indicators next to the line numbers (lines changed, added, etc.)
return {
    'gitsigns',
    event = 'DeferredUIEnter',
    after = function()require('gitsigns').setup({
        signcolumn = true,
        numhl = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'right_align',
            ignore_whitespace = true,
        },
        preview_config = {
            border = 'none',
        },
    })end,
    keys = {
        {
            ']g',
            function()
                require('gitsigns').nav_hunk('next')
            end,
            expr = true,
            mode = { 'n' },
            desc = 'Next git hunk',
        },
        {
            '[g',
            function()
                require('gitsigns').nav_hunk('prev')
            end,
            expr = true,
            mode = { 'n' },
            desc = 'Previous git hunk',
        },
        {
            '<leader>hB',
            '<cmd>lua require("gitsigns").blame_line({full=true, ignore_whitespace = true})<CR>',
            mode = { 'n' },
            desc = 'Blame line',
            noremap = true,
        },
        {
            '<leader>hR',
            ':Gitsigns reset_buffer<CR>',
            mode = { 'n' },
            desc = 'Reset buffer',
            noremap = true,
        },
        {
            '<leader>hS',
            ':Gitsigns stage_buffer<CR>',
            mode = { 'n' },
            desc = 'Stage buffer',
            noremap = true,
        },
        {
            '<leader>hb',
            ':Gitsigns toggle_current_line_blame<CR>',
            mode = { 'n' },
            desc = 'Toggle blame current line',
            noremap = true,
        },
        {
            '<leader>hd',
            ':Gitsigns diffthis<CR>',
            mode = { 'n' },
            desc = 'Diff this',
            noremap = true,
        },
        {
            '<leader>hp',
            ':Gitsigns preview_hunk<CR>',
            mode = { 'n' },
            desc = 'Preview hunk',
            noremap = true,
        },
        {
            '<leader>hr',
            ':Gitsigns reset_hunk<CR>',
            mode = { 'n' },
            desc = 'Reset hunk',
            noremap = true,
        },
        {
            '<leader>hs',
            ':Gitsigns stage_hunk<CR>',
            mode = { 'n' },
            desc = 'Stage hunk',
            noremap = true,
        },
        {
            '<leader>ht',
            ':Gitsigns toggle_deleted<CR>',
            mode = { 'n' },
            desc = 'Toggle deleted hunks',
            noremap = true,
        },
        {
            '<leader>hu',
            ':Gitsigns undo_stage_hunk<CR>',
            mode = { 'n' },
            desc = 'Undo stage hunk',
            noremap = true,
        },
        {
            '<leader>hr',
            function()
                require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end,
            mode = { 'v' },
            desc = 'Reset Hunk',
            noremap = true,
        },
        {
            '<leader>hs',
            function()
                require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end,
            mode = { 'v' },
            desc = 'Stage Hunk',
            noremap = true,
        },
    },
}
