local M = require('lualine.component'):extend()

M.processing = false
M.spinner_index = 1

local spinner_symbols = {
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
}
local spinner_symbols_len = 10

-- Initializer
function M:init(options)
    M.super.init(self, options)

    local group = vim.api.nvim_create_augroup('CodeCompanionHooks', {})

    vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = 'CodeCompanionRequest*',
        group = group,
        callback = function(request)
            if request.match == 'CodeCompanionRequestStarted' then
                self.processing = true
            elseif request.match == 'CodeCompanionRequestFinished' then
                self.processing = false
            end
        end,
    })
end

-- Function that runs every time statusline is updated
function M:update_status()
    return function()
        if self.processing then
            self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
            return 'CC ' .. spinner_symbols[self.spinner_index]
        else
            return ''
        end
    end
end

return M
