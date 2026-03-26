-- rainbow highlighting and auto-pairs
return {
    'blink.pairs',
    event = 'DeferredUIEnter',
    after = function()
        require('blink.pairs').setup({
            mappings = {
                enabled = true,
                pairs = {
                    ['|'] = {
                        {
                            '|',
                            '|',
                            languages = { 'rust' },
                        },
                    },
                },
            },
            highlights = {
                enabled = false,
                matchparen = {
                    enabled = true,
                },
            },
        })
    end,
}
