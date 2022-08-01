require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = { 'jdtls' },
    automatic_installation = true,
})
require('mason-tool-installer').setup({
    ensure_installed = {
        'codelldb',
        'eslint_d',
        'black',
        'clangd',
        'ktlint',
        'markdownlint',
        'shfmt',
        'stylua',
        'codespell',
        'vale',
        'luacheck',
        'pylint',
        'write-good',
        'yamllint',
        'cmakelang',
    },
})

local lspconfig = require('lspconfig')

local autocmd = vim.api.nvim_create_autocmd
-- local clearcmd = vim.api.nvim_clear_autocmds
local augroup = function(name)
    return vim.api.nvim_create_augroup(name, { clear = false })
end

local default_on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        require('nvim-navic').attach(client, bufnr)
    end
    if client.server_capabilities.code_lens or client.server_capabilities.codeLensProvider then
        local group = augroup('LSPRefreshLens')

        -- Code Lens
        autocmd({ 'BufEnter', 'InsertLeave' }, {
            desc = 'Auto show code lenses',
            buffer = bufnr,
            callback = vim.lsp.codelens.refresh,
            group = group,
        })
    end
    if client.server_capabilities.document_highlight or client.server_capabilities.documentHighlightProvider then
        local group = augroup('LSPHighlightSymbols')

        -- Highlight text at cursor position
        autocmd({ 'CursorHold', 'CursorHoldI' }, {
            desc = 'Highlight references to current symbol under cursor',
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
            group = group,
        })
        autocmd({ 'CursorMoved' }, {
            desc = 'Clear highlights when cursor is moved',
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
            group = group,
        })
    end
    if client.server_capabilities.document_formatting or client.server_capabilities.documentFormattingProvider then
        local group = augroup('LSPAutoFormat')

        -- auto format file on save
        autocmd({ 'BufWritePre' }, {
            desc = 'Auto format file before saving',
            buffer = bufnr,
            command = 'silent! undojoin | lua vim.lsp.buf.format({async = false})',
            group = group,
        })
    end
    -- check if this is applicable (for rust for example it is not)
    -- https://github.com/L3MON4D3/LuaSnip/wiki/Misc#improve-language-server-snippets
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

--lua
local lua_runtime = {
    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
}
for _, v in pairs(vim.api.nvim_get_runtime_file('', true)) do
    lua_runtime[v] = true
end
lspconfig.sumneko_lua.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = lua_runtime,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})
-- bash
lspconfig.bashls.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
})
-- C#
lspconfig.omnisharp.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
})
-- python
lspconfig.pyright.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
})
-- typescript
lspconfig.tsserver.setup({
    init_options = require('nvim-lsp-ts-utils').init_options,
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        default_on_attach(client, bufnr)
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
local mason_registry = require('mason-registry')
local codelldb = mason_registry.get_package('codelldb')
local extension_path = codelldb:get_install_path()
local codelldb_path = extension_path .. '/adapter/codelldb'
local liblldb_path = extension_path .. '/lldb/lib/liblldb.so'
require('rust-tools').setup({
    tools = {
        autoSetHints = true,
        hover_with_actions = true,
        inlay_hints = {
            only_current_line = false,
            show_parameter_hints = true,
            parameter_hints_prefix = '◂ ',
            other_hints_prefix = '▸ ',
        },
        hover_actions = { auto_focus = true },
    },
    dap = {
        adapter = require('rust-tools.dap').get_codelldb_adapter(codelldb_path, liblldb_path),
    },
    server = {
        on_attach = default_on_attach,
        capabilities = capabilities,
        standalone = false,
        -- cmd = rust_server:get_default_options().cmd,
        settings = {
            ['rust-analyzer'] = {
                diagnostics = {
                    enable = true,
                    -- https://github.com/rust-analyzer/rust-analyzer/issues/6835
                    disabled = { 'unresolved-macro-call' },
                    enableExperimental = true,
                },
                completion = {
                    autoself = { enable = true },
                    autoimport = { enable = true },
                    postfix = { enable = true },
                },
                imports = {
                    group = { enable = true },
                    merge = { glob = false },
                    prefix = 'self',
                    granularity = {
                        enforce = true,
                        group = 'crate',
                    },
                },
                cargo = {
                    loadOutDirsFromCheck = true,
                    autoreload = true,
                    runBuildScripts = true,
                    features = 'all',
                },
                procMacro = { enable = true },
                lens = {
                    enable = true,
                    run = { enable = true },
                    debug = { enable = true },
                    implementations = { enable = true },
                    references = {
                        adt = { enable = true },
                        enumVariant = { enable = true },
                        method = { enable = true },
                        trait = { enable = true },
                    },
                },
                hover = {
                    actions = {
                        enable = true,
                        run = { enable = true },
                        debug = { enable = true },
                        gotoTypeDef = { enable = true },
                        implementations = { enable = true },
                        references = { enable = true },
                    },
                    links = { enable = true },
                    documentation = { enable = true },
                },
                inlayHints = {
                    enable = true,
                    bindingModeHints = { enable = true },
                    chainingHints = { enable = true },
                    closingBraceHints = {
                        enable = true,
                        minLines = 0,
                    },
                    closureReturnTypeHints = { enable = 'always' },
                    lifetimeElisionHints = { enable = 'skip_trivial' },
                    typeHints = { enable = true },
                },
                checkOnSave = {
                    enable = true,
                    -- https://github.com/rust-analyzer/rust-analyzer/issues/9768
                    command = 'clippy',
                    features = 'all',
                    allTargets = true,
                },
            },
        },
    },
})
-- Cargo.toml
require('crates').setup({})
-- yaml
lspconfig.yamlls.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
})
-- json
lspconfig.jsonls.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
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
        },
    },
})
-- docker
lspconfig.dockerls.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
})
-- deno
-- ensure_server('denols'):setup({})
-- sql
lspconfig.sqlls.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
    cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
})
-- kotlin
lspconfig.kotlin_language_server.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
})

-- java
autocmd({ 'FileType' }, {
    desc = 'Start java LSP server',
    pattern = 'java',
    callback = function()
        require('jdtls').start_or_attach({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
                default_on_attach(client, bufnr)
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
    end,
})

-- general LSP config
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = true,
    virtual_text = false,
    signs = true,
})

-- show icons in the sidebar
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
    severity_sort = true,
})

-- null-ls
local null_ls = require('null-ls')
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.formatting.cmake_format,
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.formatting.fish_indent,
        null_ls.builtins.formatting.fixjson,
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.ktlint,
        null_ls.builtins.formatting.markdownlint,
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.stylua.with({
            extra_args = { '--config-path', vim.fn.expand('~/.config/stylua.toml') },
        }),
        null_ls.builtins.diagnostics.codespell.with({
            filetypes = { 'markdown', 'tex', 'asciidoc' },
        }),
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.hadolint,
        null_ls.builtins.diagnostics.ktlint,
        null_ls.builtins.diagnostics.luacheck.with({
            args = {
                '--formatter',
                'plain',
                '--config',
                '~/.config/nvim/.luacheckrc',
                '--codes',
                '--ranges',
                '--filename',
                '$FILENAME',
                '-',
            },
        }),
        null_ls.builtins.diagnostics.cppcheck,
        null_ls.builtins.diagnostics.write_good,
        null_ls.builtins.diagnostics.markdownlint,
        null_ls.builtins.diagnostics.pylint,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.vale.with({
            -- filetypes = {},
            diagnostics_postprocess = function(diagnostic)
                -- reduce the severity
                if diagnostic.severity == vim.diagnostic.severity['ERROR'] then
                    diagnostic.severity = vim.diagnostic.severity['WARN']
                elseif diagnostic.severity == vim.diagnostic.severity['WARN'] then
                    diagnostic.severity = vim.diagnostic.severity['INFO']
                end
            end,
        }),
        null_ls.builtins.code_actions.refactoring,
    },
    on_attach = default_on_attach,
})
require('lsp_signature').setup({})
require('nvim-navic').setup({
    highlight = true,
})

local eval_navic = function()
    local navic = require('nvim-navic')
    if navic.is_available() then
        return vim.api.nvim_eval("expand('%:t')") .. ' > ' .. navic.get_location()
    else
        return vim.api.nvim_buf_get_name(0)
    end
end

function winbar_eval()
    local columns = vim.api.nvim_get_option('columns')
    local sig = require('lsp_signature').status_line(columns)

    if sig == nil or sig.label == nil or sig.range == nil then
        return ' ' .. eval_navic()
    end
    local label1 = sig.label
    local label2 = ''
    if sig.range then
        label1 = sig.label:sub(1, sig.range['start'] - 1)
        label2 = sig.label:sub(sig.range['end'] + 1, #sig.label)
    end
    local doc = sig.doc or ''
    if #doc + #sig.label >= columns then
        local trim = math.max(5, columns - #sig.label - #sig.hint - 10)
        doc = doc:sub(1, trim) .. '...'
        -- lprint(doc)
    end

    return eval_navic()
        .. ' Signature: %#WinBarSignature#'
        .. label1
        .. '%*'
        .. '%#WinBarSigActParm#'
        .. sig.hint
        .. '%*'
        .. '%#WinBarSignature#'
        .. label2
end

-- sets the winbar
-- vim.wo.winbar = vim.api.nvim_eval("expand('%:t')")
vim.o.winbar = '%{%v:lua.winbar_eval()%}'
