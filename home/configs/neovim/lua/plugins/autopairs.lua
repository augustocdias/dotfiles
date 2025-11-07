-- helps with auto closing blocks
return {
    'nvim-autopairs',
    event = 'DeferredUIEnter',
    after = function()
        local npairs = require('nvim-autopairs')
        local npairs_rule = require('nvim-autopairs.rule')

        npairs.setup()

        npairs.add_rule(npairs_rule('r#"', '"#', 'rust'))
        npairs.add_rule(npairs_rule('|', '|', 'rust'))
    end,
}
