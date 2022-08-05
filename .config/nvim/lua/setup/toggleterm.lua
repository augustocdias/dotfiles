return {
    setup = function()
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
        })
        require('setup.autocommand').term_autocmds()
    end,
}
