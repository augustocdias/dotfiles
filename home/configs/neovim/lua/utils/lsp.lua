local M = {}

M.on_attach = function(client, bufnr)
    require('utils.autocommands').lsp_autocmds(client, bufnr)

    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    if client.server_capabilities.code_lens or client.server_capabilities.codeLensProvider then
        vim.lsp.codelens.enable(true, { bufnr = bufnr })
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
    return capabilities
end

return M
