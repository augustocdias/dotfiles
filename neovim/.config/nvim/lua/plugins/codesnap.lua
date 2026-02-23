-- Generates an image from selected text. Needs silicon installed (cargo install silicon)
return {
    'mistricky/codesnap.nvim',
    cmd = { 'CodeSnap', 'CodeSnapSave', 'CodeSnapASCII', 'CodeSnapHighlight' },
    opts = {
        snapshot_config = {
            window = {
                mac_window_bar = false,
            },
            code_config = {
                font_family = 'MonaspiceNe Nerd Font',
            },
            watermark = {
                content = 'github.com/augustocdias',
            },
        },
    },
}
