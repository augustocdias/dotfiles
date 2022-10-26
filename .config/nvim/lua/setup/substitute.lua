return {
    setup = function()
        require('cool-substitute').setup({
            setup_keybindings = true,
            mappings = {
                start = 'gm',
                start_and_edit = 'gM',
                start_and_edit_word = 'g!M',
                start_word = 'g!m',
                apply_substitute_and_next = 'm',
                apply_substitute_and_prev = 'M',
                apply_substitute_all = 'ga',
            },
        })
    end,
    status_line = function()
        return {
            require('cool-substitute.status').status_with_icons,
            color = function()
                return { fg = require('cool-substitute.status').status_color() }
            end,
        }
    end,
}
