return {
    setup = function()
        require('here-term').setup({
            mappings = {
                toggle = '<leader>sh',
                kill = '<leader>ss',
            },
        })
        -- require('setup.autocommand').term_autocmds()
    end,
}
