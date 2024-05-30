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
                if not vim.g.SessionLoad then
                    vim.cmd(':startinsert')
                end
            end,
        })
        autocmd({ 'BufEnter' }, {
            desc = 'Set terminal to insert mode',
            group = termgroup,
            pattern = 'term://*',
            callback = function()
                if not vim.g.SessionLoad then
                    vim.cmd(':startinsert')
                end
            end,
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
                callback = function()
                    vim.lsp.codelens.refresh({ bufnr = bufnr })
                end,
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
            -- set the autoformat flag
            vim.b.autoformat = vim.g.autoformat

            -- auto format file on save
            autocmd({ 'BufWritePre' }, {
                desc = 'Auto format file before saving',
                buffer = bufnr,
                callback = function()
                    if vim.b.autoformat then
                        vim.lsp.buf.format({ async = false })
                    end
                end,
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

        local packer_group = augroup('LazyDone')
        autocmd('User', {
            group = packer_group,
            pattern = 'LazyUpdate',
            callback = function() -- Autocompile colorscheme
                require('catppuccin').compile()
            end,
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
