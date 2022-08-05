return {
    setup = function()
        require('filetype').setup({
            overrides = {
                complex = {
                    ['Dockerfile*'] = 'dockerfile',
                    -- Set the filetype of any full filename matching the regex to gitconfig
                    ['.*git/config'] = 'gitconfig', -- Included in the plugin
                },
            },
        })
    end,
}
