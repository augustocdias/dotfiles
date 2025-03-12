-- gx opens urls, github issues etc in the browser

return {
    'chrishrb/gx.nvim',
    event = 'VeryLazy',
    submodules = false,
    opts = {
        handlers = {
            rust = {
                filetype = { 'toml' },
                filename = 'Cargo.toml',
                handle = function(mode, line, _)
                    local crate = require('gx.helper').find(line, mode, '(%w+)%s-=%s')
                    if crate then
                        return 'https://crates.io/crates/' .. crate
                    end
                end,
            },
        },
        handler_options = {
            search_engine = 'duckduckgo',
        },
    },
    keys = {
        {
            'gx',
            '<CMD>Browse<CR>',
            mode = { 'n', 'x' },
            desc = 'Open links in browser',
            silent = true,
        },
    },
}
