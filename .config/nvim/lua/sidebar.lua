local M = {
    _opened = '',
    _sidebars = {},
}
function M:register_sidebar(name, open, close)
    self._sidebars[name] = {
        open = open,
        close = close,
    }
end

function M:toggle(name)
    if self._opened == '' then
        self._opened = name
        self._sidebars[name].open()
    elseif self._opened ~= name then
        self._sidebars[self._opened].close()
        self._sidebars[name].open()
        self._opened = name
    else
        self._opened = ''
        self._sidebars[name].close()
    end
end

function M:close()
    if self._opened ~= '' then
        self._sidebars[self._opened].close()
        self._opened = ''
    end
end

return M
