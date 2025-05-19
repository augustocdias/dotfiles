-- collection of LSP configurations for nvim

return {
    'neovim/nvim-lspconfig',
    priority = 100,
    lazy = false,
    dependencies = {
        'b0o/schemastore.nvim', -- adds schemas for json lsp
    },
    config = function()
        local lsp_utils = require('utils.lsp')
        local lspconfig = require('lspconfig')

        -- general LSP config
        vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            underline = true,
            update_in_insert = true,
            virtual_text = false,
            signs = true,
        })

        -- TODO: check if this works
        vim.fn.sign_define(
            'LightBulbSign',
            { text = '󰛩', texthl = 'LspDiagnosticsDefaultInformation', numhl = 'LspDiagnosticsDefaultInformation' }
        )

        vim.diagnostic.config({
            severity_sort = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '',
                    [vim.diagnostic.severity.WARN] = '',
                    [vim.diagnostic.severity.INFO] = '',
                    [vim.diagnostic.severity.HINT] = '',
                },
                numhl = {
                    [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
                    [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
                    [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
                    [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
                },
            },
        })

        -- bash
        lspconfig.bashls.setup({
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- yaml
        lspconfig.yamlls.setup({
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
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
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
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
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        lspconfig.docker_compose_language_service.setup({
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- toml
        lspconfig.taplo.setup({
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- harper (grammar checker)
        lspconfig.harper_ls.setup({
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- godot
        lspconfig.gdscript.setup({
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- lua
        local lua_runtime = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        }
        for _, v in pairs(vim.api.nvim_get_runtime_file('', true)) do
            lua_runtime[v] = true
        end
        lspconfig.lua_ls.setup({
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
            settings = {
                Lua = {
                    format = {
                        enabled = false,
                        defaultConfig = {
                            indent_style = 'space',
                        },
                    },
                    runtime = {
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { 'vim', 'Snacks' },
                        disable = { 'inject-field' },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = lua_runtime,
                        -- stop the annoying message from luassert
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        })
    end,
    keys = {
        {
            'gD',
            vim.lsp.buf.declaration,
            mode = { 'n' },
            desc = 'Go to declaration',
            silent = true,
        },
        {
            'gt',
            vim.lsp.buf.type_definition,
            mode = { 'n' },
            desc = 'Go to type definition',
            silent = true,
        },
        {
            'gd',
            vim.lsp.buf.definition,
            mode = { 'n' },
            desc = 'Go to definition',
            silent = true,
        },
        {
            'gw',
            ':vsplit | lua vim.lsp.buf.definition()<CR>',
            mode = { 'n' },
            desc = 'Go to definition',
            silent = true,
        },
        {
            'gi',
            vim.lsp.buf.implementation,
            mode = { 'n' },
            desc = 'Go to implementation',
            silent = true,
        },
        {
            'gr',
            function()
                vim.lsp.buf.references({ includeDeclaration = false })
            end,
            mode = { 'n' },
            desc = 'Find references',
            silent = true,
        },
        {
            '<M-s>',
            vim.lsp.buf.signature_help,
            mode = { 'i' },
            desc = 'Signature help',
            silent = true,
        },
        {
            '<M-s>',
            vim.lsp.buf.signature_help,
            mode = { 'n' },
            desc = 'Signature help',
            silent = true,
        },
        {
            '<M-f>',
            function()
                vim.lsp.buf.format({ async = false })
            end,
            mode = { 'n' },
            desc = 'Format code',
            silent = true,
        },
        {
            '<leader>la',
            '<cmd>lua vim.lsp.buf.code_action()<CR>',
            mode = { 'n' },
            desc = 'Code actions',
            noremap = true,
        },
        {
            '<leader>lb',
            '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
            mode = { 'n' },
            desc = 'Show line diagnostics',
            noremap = true,
        },
        {
            '<leader>lc',
            function()
                vim.b.autoformat = not vim.b.autoformat
            end,
            mode = { 'n' },
            desc = 'Toggle autoformat',
            noremap = true,
        },
        {
            '<leader>lf',
            '<cmd>lua vim.lsp.buf.format({ async = false })<CR>',
            mode = { 'n' },
            desc = 'Format',
            noremap = true,
        },
        {
            '<leader>ll',
            '<cmd>lua vim.lsp.codelens.run()<CR>',
            mode = { 'n' },
            desc = 'Code Lens',
            noremap = true,
        },
        {
            '<leader>lm',
            '<cmd>lua vim.lsp.buf.rename()<CR>',
            mode = { 'n' },
            desc = 'Rename symbol',
            noremap = true,
        },
        {
            '<leader>lq',
            '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>',
            mode = { 'n' },
            desc = 'Diagnostic set loclist',
            noremap = true,
        },
        {
            '<leader>la',
            '<cmd>lua vim.lsp.buf.range_code_action()<CR>',
            mode = { 'v' },
            desc = 'Range Code Action',
            noremap = true,
        },
    },
}
