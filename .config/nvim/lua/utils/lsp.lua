local M = {}

M.on_attach = function(client, bufnr)
    require('setup.autocommand').lsp_autocmds(client, bufnr)
    -- check if this is applicable (for rust for example it is not)
    -- https://github.com/L3MON4D3/LuaSnip/wiki/Misc#improve-language-server-snippets

    -- enable inlay hints if server supports it
    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
end
M.capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

    -- workaround until neovim supports multiple client encodings
    capabilities = vim.tbl_deep_extend('force', capabilities, {
        offsetEncoding = { 'utf-16' },
        general = {
            positionEncodings = { 'utf-16' },
        },
    })
    -- Tell the server the capability of foldingRange,
    -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
    -- https://github.com/neovim/neovim/pull/14306
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }
    return capabilities
end

return M
