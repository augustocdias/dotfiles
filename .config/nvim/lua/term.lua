require('toggleterm').setup({
    size = function(term)
        if term.direction == 'horizontal' then
            return 15
        elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
        end
    end,
    hide_numbers = false,
    shade_terminals = false,
    start_in_insert = false,
    insert_mappings = false, -- no default mapping
    persist_size = true,
    direction = 'horizontal',
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
        border = 'curved',
        highlights = {
            border = 'Normal',
            background = 'Normal',
        },
    },
    winbar = {
        enabled = true,
    },
    on_open = function()
        for _, match in ipairs(vim.fn.getmatches()) do
            if match['group'] == 'ExtraWhitespace' then
                vim.fn.matchdelete(match['id'])
            end
        end
        vim.cmd('startinsert')
    end,
})

local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

local termgroup = augroup('ToggleTerm')

autocmd({ 'TermOpen' }, {
    desc = 'Set terminal keymaps',
    pattern = 'term://*toggleterm#*',
    group = termgroup,
    callback = function()
        local opts = { noremap = true }
        vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
    end,
})
autocmd({ 'BufEnter' }, {
    desc = 'Set terminal to insert mode',
    group = termgroup,
    pattern = 'term://*',
    command = 'startinsert',
})
