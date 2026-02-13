-- Generates an image from selected text. Needs silicon installed (cargo install silicon)
return {
    'codesnap',
    cmd = { 'CodeSnap', 'CodeSnapSave', 'CodeSnapASCII', 'CodeSnapHighlight' },
    after = function()
        require('codesnap').setup({
            snapshot_config = {
                code_config = {
                    font_family = 'MonaspiceNe Nerd Font',
                },
                watermark = {
                    content = 'github.com/augustocdias',
                },
            },
        })
    end,
}
