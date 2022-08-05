return {
    term_autocmds = function()
        local autocmd = vim.api.nvim_create_autocmd
        local augroup = function(name)
            return vim.api.nvim_create_augroup(name, { clear = true })
        end

        local termgroup = augroup('ToggleTerm')

        autocmd({ 'TermOpen' }, {
            desc = 'Set terminal keymaps',
            pattern = 'term://*toggleterm#*',
            group = termgroup,
            callback = function()
                local opts = { noremap = true }
                vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], opts)
                vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
                vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
                vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
                vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
                vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
                vim.cmd(':startinsert')
            end,
        })
        autocmd({ 'BufEnter' }, {
            desc = 'Set terminal to insert mode',
            group = termgroup,
            pattern = 'term://*',
            command = 'startinsert',
        })
    end,
    lsp_autocmds = function(client, bufnr)
        local autocmd = vim.api.nvim_create_autocmd
        local augroup = function(name)
            return vim.api.nvim_create_augroup(name, { clear = false })
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
        local group = augroup('LSPDianostics')
        autocmd({ 'CursorHold', 'CursorHoldI' }, {
            desc = 'Show box with diagnostics for current line',
            pattern = '*',
            callback = function()
                vim.diagnostic.open_float({ focusable = false })
            end,
            group = group,
        })
    end,
    setup = function()
        local autocmd = vim.api.nvim_create_autocmd
        local augroup = function(name)
            return vim.api.nvim_create_augroup(name, { clear = true })
        end

        autocmd({ 'BufWritePost' }, {
            desc = 'Auto update packer plugins once the plugins definition file is changed',
            pattern = 'plugins.lua,*nvim/lua/plugins/*.lua',
            command = 'source <afile> | PackerSync',
            group = augroup('PackerUserConfig'),
        })

        autocmd({ 'ModeChanged' }, {
            desc = 'Stop snippets when you leave to normal mode',
            pattern = '*',
            callback = function()
                if
                    ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
                    and require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()]
                    and not require('luasnip').session.jump_active
                then
                    require('luasnip').unlink_current()
                end
            end,
        })

        autocmd({ 'BufRead' }, {
            desc = "Prevent accidental writes to buffers that shouldn't be edited",
            pattern = '*.orig',
            command = 'set readonly',
        })

        autocmd({ 'TextYankPost' }, {
            desc = 'Highlight yanked text',
            pattern = '*',
            callback = function()
                require('vim.highlight').on_yank({ higroup = 'IncSearch', timeout = 1000 })
            end,
        })

        autocmd({ 'OptionSet' }, {
            desc = ' Automatically switch theme to dark/light when background set',
            pattern = 'background',
            callback = function()
                vim.cmd('Catppuccin ' .. (vim.v.option_new == 'light' and 'latte' or 'mocha'))
            end,
        })
    end,
}
