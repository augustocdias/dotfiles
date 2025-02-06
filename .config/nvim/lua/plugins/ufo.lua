-- handling folds based on LSP and treesitter

-- FIXME: diagnostics and foldings are overlapping
local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local totalLines = vim.api.nvim_buf_line_count(0)
    local foldedLines = endLnum - lnum
    local suffix = (' 󰹷 %d %d%%'):format(foldedLines, foldedLines / totalLines * 100)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    local rAlignAppndx = math.max(math.min(vim.opt.textwidth['_value'], width - 1) - curWidth - sufWidth, 0)
    suffix = (' '):rep(rAlignAppndx) .. suffix
    table.insert(newVirtText, { suffix, 'MoreMsg' })
    return newVirtText
end

return {
    'kevinhwang91/nvim-ufo',
    enabled = not vim.g.vscode,
    event = 'VeryLazy',
    dependencies = { 'kevinhwang91/promise-async', 'luukvbaal/statuscol.nvim' },
    config = function()
        require('ufo').setup({
            close_fold_kinds_for_ft = {
                default = { 'imports', 'comment' },
                json = { 'array' },
            },
            preview = {
                win_config = {
                    border = 'none',
                },
            },
            fold_virt_text_handler = handler,
        })
        local builtin = require('statuscol.builtin')
        require('statuscol').setup({
            bt_ignore = { 'terminal', 'nofile' },
            relculright = true,
            segments = {
                -- fold -> sign -> anything else -> line number + separator or gitsigns
                { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
                {
                    sign = { namespace = { 'diagnostic' }, maxwidth = 1, colwidth = 1, auto = false, foldclosed = true },
                    click = 'v:lua.ScSa',
                },
                {
                    sign = {
                        name = { '.*' },
                        text = { '.*' },
                        maxwidth = 2,
                        colwidth = 2,
                        auto = true,
                        foldclosed = true,
                    },
                    click = 'v:lua.ScSa',
                },
                { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
                {
                    sign = {
                        namespace = { 'gitsigns' },
                        fillchar = '│',
                        maxwidth = 1,
                        colwidth = 1,
                        wrap = true,
                        foldclosed = true,
                    },
                    click = 'v:lua.ScSa',
                },
            },
        })
    end,
    keys = {
        {
            'zR',
            function()
                require('ufo').openAllFolds()
            end,
            mode = { 'n' },
            desc = 'Open All Folds',
            silent = true,
        },
        {
            'zM',
            function()
                require('ufo').closeAllFolds()
            end,
            mode = { 'n' },
            silent = true,
            desc = 'Close All Folds',
        },
    },
}
