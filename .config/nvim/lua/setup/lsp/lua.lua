return {
    setup = function(lspconfig, capabilities, on_attach)
        local lua_runtime = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        }
        for _, v in pairs(vim.api.nvim_get_runtime_file('', true)) do
            lua_runtime[v] = true
        end
        lspconfig.lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { 'vim' },
                        disable = { 'inject-field' },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = lua_runtime,
                        -- stop the annoying message from luassert
                        checkThirdParty = false,
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {
                        enable = false,
                    },
                },
            },
        })
    end,
}
