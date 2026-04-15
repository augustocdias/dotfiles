local M = {}

local LSPMUX_HOST = '127.0.0.1'
local LSPMUX_PORT = 27631

--- Returns a cmd function that connects to lspmux via TCP.
--- Use as the `cmd` field in vim.lsp.config or rustaceanvim server config.
---@param server_name string The LSP server binary name (e.g. "rust-analyzer", "nixd")
---@return function
M.lspmux_cmd = function(server_name)
    return vim.lsp.rpc.connect(LSPMUX_HOST, LSPMUX_PORT)
end

--- Returns the lspMux initialization settings to merge into the server's
--- settings or init_options so lspmux knows which server to spawn.
---@param server_name string The LSP server binary name
---@return table
M.lspmux_init = function(server_name)
    return {
        lspMux = {
            version = '1',
            method = 'connect',
            server = server_name,
        },
    }
end

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
