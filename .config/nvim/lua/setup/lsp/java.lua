return {
    setup = function(capabilities, on_attach)
        require('jdtls').start_or_attach({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
                on_attach(client, bufnr)
                require('jdtls.setup').add_commands()
                require('jdtls').setup_dap()
            end,
            -- FIXME: if I ever need to use java again
            cmd = java_server:get_default_options().cmd,
            root_dir = require('jdtls.setup').find_root({
                'pom.xml',
                'settings.gradle',
                'settings.gradle.kts',
                'build.gradle',
                'build.gradle.kts',
            }),
        })
    end,
}
