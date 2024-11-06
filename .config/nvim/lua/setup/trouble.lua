return {
    setup = function()
        require('trouble').setup({
            modes = {
                diagnostics = {
                    filter = function(item)
                        return item.filename:find((vim.loop or vim.uv).cwd(), 1, true)
                    end,
                },
            },
        })
    end,
}
