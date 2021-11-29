local lsp_status = require('lsp-status')
lsp_status.register_progress()

local function ensure_server(name)
    local lsp_installer = require('nvim-lsp-installer.servers')
    local _, server = lsp_installer.get_server(name)
    if not server:is_installed() then
        server:install()
    end
    return server
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
capabilities = vim.tbl_extend('keep', capabilities, lsp_status.capabilities)

--lua
ensure_server('sumneko_lua'):setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
})
-- bash
ensure_server('bashls'):setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
})
-- C#
ensure_server('omnisharp'):setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
})
-- python
ensure_server('pyright'):setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
})
-- typescript
ensure_server('tsserver'):setup({
    init_options = require('nvim-lsp-ts-utils').init_options,
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        lsp_status.on_attach(client)
        -- disable tsserver formatting if you plan on formatting via null-ls
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false

        local ts_utils = require('nvim-lsp-ts-utils')

        -- defaults
        ts_utils.setup({
            debug = false,
            disable_commands = false,
            enable_import_on_completion = true,

            -- import all
            import_all_timeout = 5000, -- ms
            -- lower numbers indicate higher priority
            import_all_priorities = {
                same_file = 1, -- add to existing import statement
                local_files = 2, -- git files or files with relative path markers
                buffer_content = 3, -- loaded buffer content
                buffers = 4, -- loaded buffer names
            },
            import_all_scan_buffers = 100,
            import_all_select_source = false,

            -- eslint
            eslint_enable_code_actions = true,
            eslint_enable_disable_comments = true,
            eslint_bin = 'eslint_d',
            eslint_enable_diagnostics = true,
            eslint_opts = {},

            -- formatting
            enable_formatting = true,
            formatter = 'eslint_d',
            formatter_opts = {},

            -- update imports on file move
            update_imports_on_move = true,
            require_confirmation_on_move = false,
            watch_dir = nil,

            -- filter diagnostics
            filter_out_diagnostics_by_severity = {},
            filter_out_diagnostics_by_code = {},

            -- inlay hints
            auto_inlay_hints = true,
            inlay_hints_highlight = 'Comment',
        })

        -- required to fix code action ranges and filter diagnostics
        ts_utils.setup_client(client)

        -- no default maps, so you may want to define some here
        local opts = { silent = true }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gs', ':TSLspOrganize<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gf', ':TSLspRenameFile<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 'go', ':TSLspImportAll<CR>', opts)
    end,
})
-- rust
-- FIXME: version used by lspinstall is too old
-- local rust_server = ensure_server('rust_analyzer')
require('rust-tools').setup({
    tools = {
        autoSetHints = true,
        hover_with_actions = true,
        inlay_hints = {
            only_current_line = false,
            show_parameter_hints = true,
            parameter_hints_prefix = '',
            other_hints_prefix = '',
        },
        hover_actions = {
            auto_focus = true,
        },
        debuggables = {
            use_telescope = true,
        },
        runnables = {
            use_telescope = true,
        },
    },
    server = {
        on_attach = lsp_status.on_attach,
        capabilities = capabilities,
        -- cmd = rust_server:get_default_options().cmd,
        settings = {
            ['rust-analyzer'] = {
                assist = {
                    importGranularity = 'module',
                    importPrefix = 'by_self',
                },
                diagnostics = {
                    -- https://github.com/rust-analyzer/rust-analyzer/issues/6835
                    disabled = { 'unresolved-macro-call' },
                },
                completion = {
                    autoimport = {
                        enable = true,
                    },
                    postfix = {
                        enable = true,
                    },
                },
                cargo = {
                    loadOutDirsFromCheck = true,
                    autoreload = true,
                    runBuildScripts = true,
                },
                procMacro = {
                    enable = true,
                },
                lens = {
                    enable = true,
                    run = true,
                    methodReferences = true,
                    implementations = true,
                },
                hoverActions = {
                    enable = true,
                },
                inlayHints = {
                    chainingHintsSeparator = '‣ ',
                    typeHintsSeparator = '‣ ',
                    typeHints = true,
                },
                checkOnSave = {
                    enable = true,
                    command = 'clippy',
                    allFeatures = true,
                },
            },
        },
    },
})
-- Cargo.toml
require('crates').setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
})
-- yaml
ensure_server('yamlls'):setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
})
-- json
local jsonls = ensure_server('jsonls')
jsonls:setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
    commands = {
        Format = {
            function()
                vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line('$'), 0 })
            end,
        },
    },
})
-- docker
ensure_server('dockerls'):setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
})
-- deno
-- ensure_server('denols'):setup({})
-- sql
ensure_server('sqlls'):setup({
    on_attach = lsp_status.on_attach,
    capabilities = capabilities,
    cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
})
-- java
local java_server = ensure_server('jdtls')
function start_java()
    require('jdtls').start_or_attach({
        capabilities = capabilities,
        on_attach = function(client)
            lsp_status.on_attach(client)
            require('jdtls.setup').add_commands()
        end,
        cmd = java_server:get_default_options().cmd,
        root_dir = require('jdtls.setup').find_root({
            'pom.xml',
            'settings.gradle',
            'settings.gradle.kts',
            'build.gradle',
            'build.gradle.kts',
        }),
    })
end
vim.api.nvim_command([[autocmd FileType java lua start_java() ]])

-- general LSP config
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = true,
    virtual_text = false,
    signs = true,
})

-- show icons in the sidebar
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Information = ' ' }

for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
    severity_sort = true,
})

-- null-ls
local null_ls = require('null-ls')
null_ls.config({
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.formatting.cmake_format,
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.formatting.fish_indent,
        null_ls.builtins.formatting.fixjson,
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.markdownlint,
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.stylua.with({
            extra_args = { '--config-path', vim.fn.expand('~/.config/stylua.toml') },
        }),
        null_ls.builtins.diagnostics.codespell.with({
            filetypes = { 'txt', 'md' },
        }),
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.hadolint,
        null_ls.builtins.diagnostics.luacheck,
        null_ls.builtins.diagnostics.cppcheck,
        null_ls.builtins.diagnostics.write_good,
        null_ls.builtins.diagnostics.markdownlint,
        null_ls.builtins.diagnostics.pylint,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.code_actions.refactoring,
    },
})
require('lspconfig')['null-ls'].setup({})
require('lsp_signature').setup({})
