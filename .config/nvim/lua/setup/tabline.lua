return {
    setup = function()
        require('tabby.tabline').use_preset('tab_only', {
            theme = {
                fill = 'TabLineFill', -- tabline background
                head = 'TabLine', -- head element highlight
                current_tab = 'TabLineSel', -- current tab label highlight
                tab = 'TabLine', -- other tab label highlight
                win = 'TabLine', -- window highlight
                tail = 'TabLine', -- tail element highlight
            },
            nerdfont = true, -- whether use nerdfont
        })
        -- require('scope').setup()

        -- Set barbar's options
        -- require('bufferline').setup({
        --     animation = true,
        --     auto_hide = false,
        --     tabpages = true,
        --     closable = true,
        --     -- left-click: go to buffer
        --     -- middle-click: delete buffer
        --     clickable = true,
        --     -- if set to 'numbers', will show buffer index in the tabline
        --     -- if set to 'both', will show buffer index and icons in the tabline
        --     icons = 'both',
        --     icon_separator_active = ' ',
        --     icon_separator_inactive = ' ',
        --     icon_close_tab = '',
        --     icon_close_tab_modified = '●',
        --     icon_pinned = '車',
        --     insert_at_end = true,
        --     maximum_padding = 1,
        --     maximum_length = 30,
        --     -- If set, the letters for each buffer in buffer-pick mode will be
        --     -- assigned based on their name. Otherwise or in case all letters are
        --     -- already assigned, the behavior is to assign letters in order of
        --     -- usability (see order below)
        --     semantic_letters = true,
        --     -- New buffer letters are assigned in this order. This order is
        --     -- optimal for the qwerty keyboard layout but might need adjustement
        --     -- for other layouts.
        --     letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',
        -- })
    end,
}
