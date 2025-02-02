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

M.config_defaults = function()
    local lspconfig = require('lspconfig')
    -- bash
    lspconfig.bashls.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
    })
    -- yaml
    lspconfig.yamlls.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
        settings = {
            yaml = {
                schemaStore = {
                    enable = false,
                    url = 'https://www.schemastore.org/api/json/catalog.json',
                },
                schemas = require('schemastore').yaml.schemas(),
                format = {
                    enable = true,
                },
            },
        },
    })
    -- json
    lspconfig.jsonls.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
        commands = {
            Format = {
                function()
                    vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line('$'), 0 })
                end,
            },
        },
        settings = {
            json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
            },
        },
    })
    -- docker
    lspconfig.dockerls.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
    })
    -- toml
    lspconfig.taplo.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
    })
    -- sql
    lspconfig.sqlls.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
        cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
    })
    -- harper (grammar checker)
    lspconfig.harper_ls.setup({
        on_attach = M.on_attach,
        capabilities = M.capabilities(),
    })
end
M.setup = function()
    local lspconfig = require('lspconfig')
    require('mason').setup()
    require('mason-lspconfig').setup({
        ensure_installed = { 'rust_analyzer' },
        automatic_installation = true,
    })
    require('mason-tool-installer').setup({
        ensure_installed = {
            'codelldb',
            'black',
            'markdownlint',
            'shfmt',
            'stylua',
            'codespell',
            'vale',
            'selene',
            'write-good',
            'yamllint',
        },
    })
    -- general LSP config
    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        update_in_insert = true,
        virtual_text = false,
        signs = true,
    })

    -- show icons in the column
    local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

    for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
    vim.fn.sign_define(
        'LightBulbSign',
        { text = '󰛨 ', texthl = 'LspDiagnosticsDefaultInformation', numhl = 'LspDiagnosticsDefaultInformation' }
    )

    vim.diagnostic.config({
        severity_sort = true,
    })
    return lspconfig
end
return M
