return {
    setup = function()
        require('gx').setup({
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
        })
    end,
}
