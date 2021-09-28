local nvim_lsp = require'lspconfig'
local lsp_status = require('lsp-status')
lsp_status.register_progress()

-- python
nvim_lsp.pyright.setup{}
-- typescript
nvim_lsp.tsserver.setup{}
-- rust
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
        settings = {
            ['rust-analyzer'] = {
                assist = {
                    importGranularity = 'module',
                    importPrefix = 'by_self',
                },
                diagnostics = {
                    disabled = { 'unresolved-proc-macro', 'macro-error' }
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
                }
            }
        }
    }
})
-- json
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
nvim_lsp.jsonls.setup {
    capabilities = capabilities,
    commands = {
      Format = {
        function()
          vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line('$'),0})
        end
      }
    }
}
-- docker
nvim_lsp.dockerls.setup{}
-- deno
nvim_lsp.denols.setup{}
-- sql
nvim_lsp.sqlls.setup{
  cmd = {'sql-language-server', 'up', '--method', 'stdio'};
}

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = true,
    virtual_text = false,
    signs = true,
    -- virtual_text = {
    --   spacing = 4,
    --   prefix = ' '
    -- }
  }
)

-- show icons in the sidebar
local signs = { Error = ' ', Warning = ' ', Hint = ' ', Information = ' ' }

for type, icon in pairs(signs) do
    local hl = 'LspDiagnosticsSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

-- require'navigator'.setup({
--     code_action_icon = ' ',
--     default_mapping = false,
--     treesitter_analysis = true,
--     transparency = 30,
--     -- check if already has it
--     -- default_mapping = false,
--     treesitter_analysis = true,
--     code_action_prompt = { enable = true, sign = false, sign_priority = 40, virtual_text = true },
--     lsp = {
--         disable_lsp = {
--             "angularls", "gopls", "flow", "julials", "pylsp", "jedi_language_server", "html", "solargraph", "cssls",
--             "clangd", "ccls",   "graphql", "dartls", "dotls", "nimls", "intelephense", "vuels", "phpactor", "omnisharp",
--             "r_language_server", "terraformls"
--         },
--         format_on_save = true,
--         diagnostic_virtual_text = false,
--     }
-- })

