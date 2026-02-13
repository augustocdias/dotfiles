-- collection of LSP configurations for nvim

return {
    'neovim/nvim-lspconfig',
    priority = 100,
    lazy = false,
    dependencies = {
        'b0o/schemastore.nvim', -- adds schemas for json lsp
        {
            'kosayoda/nvim-lightbulb',
            opts = {
                autocmd = { enabled = true },
                sign = { text = '󰛩' },
            },
        },
    },
    config = function()
        local lsp_utils = require('utils.lsp')

        vim.diagnostic.config({
            virtual_text = false,
            underline = true,
            severity_sort = true,
            update_in_insert = true,
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

        -- vim.lsp.on_type_formatting.enable()

        -- bash
        vim.lsp.enable('bashls')
        vim.lsp.config('bashls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- yaml
        vim.lsp.enable('yamlls')
        vim.lsp.config('yamlls', {
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
        vim.lsp.enable('jsonls')
        vim.lsp.config('jsonls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = { enable = true },
                },
            },
        })
        -- eslint
        vim.lsp.enable('eslint')
        vim.lsp.config('eslint', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- docker
        vim.lsp.enable('dockerls')
        vim.lsp.config('dockerls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        vim.lsp.enable('docker_compose_language_service')
        vim.lsp.config('docker_compose_language_service', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- toml
        vim.lsp.enable('taplo')
        vim.lsp.config('taplo', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })
        -- harper (grammar checker)
        vim.lsp.enable('harper_ls')
        vim.lsp.config('harper_ls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- godot
        vim.lsp.enable('gdscript')
        vim.lsp.config('gdscript', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- lua
        vim.lsp.enable('emmylua_ls')
        vim.lsp.config('emmylua_ls', {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.capabilities(),
        })

        -- rust diagnostics (faster than rust-analyzer)
        -- vim.lsp.enable('bacon_ls')
        -- vim.lsp.config('bacon_ls', {
        --     on_attach = lsp_utils.on_attach,
        --     capabilities = lsp_utils.capabilities(),
        --     init_options = {
        --         useBaconBackend = false,
        --         updateOnSave = true,
        --         updateOnChange = true,
        --         updateOnSaveWaitMillis = 1000,
        --         cargoCommandArgs = 'clippy --target x86_64-pc-windows-msvc --tests --feature use-codebase-lib --all-targets --message-format json-diagnostic-rendered-ansi',
        --     },
        -- })
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
                require('conform').format({ async = false, lsp_format = 'fallback' })
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
            vim.diagnostic.open_float,
            mode = { 'n' },
            desc = 'Show line diagnostics',
            noremap = true,
        },
        {
            '<leader>lf',
            function()
                require('conform').format({ async = false, lsp_format = 'fallback' })
            end,
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
            vim.diagnostic.setloclist,
            mode = { 'n' },
            desc = 'Diagnostic set loclist',
            noremap = true,
        },
        {
            '<leader>la',
            '<cmd>lua vim.lsp.buf.code_action()<CR>',
            mode = { 'v' },
            desc = 'Code Action',
            noremap = true,
        },
    },
}
