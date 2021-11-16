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

--lua
ensure_server('sumneko_lua'):setup({})
-- bash
ensure_server('bashls'):setup({})
-- C#
ensure_server('omnisharp'):setup({})
-- python
ensure_server('pyright'):setup({})
-- typescript
ensure_server('tsserver'):setup({})
-- rust
-- FIXME: version used by lspinstall is too old
-- local rust_server = ensure_server('rust_analyzer')
require('rust-tools').setup({
    tools = {
        autoSetHints = true,
        hover_with_actions = true,
        inlay_hints = {
            show_parameter_hints = true,
            parameter_hints_prefix = '',
            other_hints_prefix = '',
        },
    },
    server = {
        on_attach = lsp_status.on_attach,
        capabilities = lsp_status.capabilities,
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
require('crates').setup({})
-- yaml
ensure_server('yamlls'):setup({})
-- json
local jsonls = ensure_server('jsonls')
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
jsonls:setup({
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
ensure_server('dockerls'):setup({})
-- deno
-- ensure_server('denols'):setup({})
-- sql
ensure_server('sqlls'):setup({
    cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
})
-- java
-- TODO: config to not auto start
-- local java_server = ensure_server('jdtls')
-- java_server:setup()
-- require('jdtls').start_or_attach({
--     cmd = java_server:get_default_options().cmd,
--     root_dir = require('jdtls.setup').find_root({
--         'pom.xml',
--         'settings.gradle',
--         'settings.gradle.kts',
--         'build.gradle',
--         'build.gradle.kts'
--     })
-- })

-- general LSP config
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = true,
    virtual_text = false,
    signs = true,
})

-- show icons in the sidebar
local signs = { Error = ' ', Warning = ' ', Hint = ' ', Information = ' ' }

for type, icon in pairs(signs) do
    local hl = 'LspDiagnosticsSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

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
        null_ls.builtins.diagnostics.codespell,
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
