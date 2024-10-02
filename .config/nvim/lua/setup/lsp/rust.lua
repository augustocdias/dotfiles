return {
    setup = function(capabilities, on_attach)
        -- Cargo.toml
        require('crates').setup({
            lsp = {
                enabled = true,
                on_attach = on_attach,
                actions = true,
                completion = false, -- enabled directly into cmp (true will show duplicate)
                hover = true,
            },
            completion = {
                crates = {
                    enabled = true,
                },
                cmp = {
                    enabled = true,
                },
            },
        })
        return {
            tools = {
                reload_workspace_from_cargo_toml = true,
                hover_actions = {
                    replace_builtin_hover = false,
                },
                float_win_config = {
                    auto_focus = true,
                },
            },
            server = {
                on_attach = on_attach,
                capabilities = capabilities,
                standalone = false,
                settings = {
                    ['rust-analyzer'] = {
                        diagnostics = {
                            enable = true,
                            enableExperimental = true,
                        },
                        completion = {
                            autoself = { enable = true },
                            autoimport = { enable = true },
                            postfix = { enable = true },
                        },
                        imports = {
                            group = { enable = true },
                            merge = { glob = false },
                            prefix = 'self',
                            preferPrelude = true,
                            granularity = {
                                enforce = true,
                                group = 'crate',
                            },
                        },
                        cargo = {
                            loadOutDirsFromCheck = true,
                            autoreload = true,
                            runBuildScripts = true,
                            features = 'all',
                            allTargets = true,
                        },
                        procMacro = {
                            enable = true,
                            attributes = { enable = true },
                        },
                        lens = {
                            enable = true,
                            run = { enable = true },
                            debug = { enable = true },
                            implementations = { enable = true },
                            references = {
                                adt = { enable = true },
                                enumVariant = { enable = true },
                                method = { enable = true },
                                trait = { enable = true },
                            },
                        },
                        hover = {
                            actions = {
                                enable = true,
                                run = { enable = true },
                                debug = { enable = true },
                                gotoTypeDef = { enable = true },
                                implementations = { enable = true },
                                references = { enable = true },
                            },
                            links = { enable = true },
                            documentation = { enable = true },
                        },
                        inlayHints = {
                            enable = true,
                            bindingModeHints = { enable = true },
                            chainingHints = { enable = true },
                            closingBraceHints = {
                                enable = true,
                                minLines = 0,
                            },
                            closureCaptureHints = { enbale = true },
                            closureReturnTypeHints = { enable = 'always' },
                            lifetimeElisionHints = {
                                enable = 'skip_trivial',
                                useParameterNames = true,
                            },
                            typeHints = { enable = true },
                            implicitDrops = { enable = true },
                        },
                        typing = {
                            autoClosingAngleBrackets = { enable = true },
                        },
                        interpret = { tests = true },
                        checkOnSave = true,
                        check = {
                            -- https://github.com/rust-analyzer/rust-analyzer/issues/9768
                            command = 'clippy',
                            features = 'all',
                            allTargets = true,
                        },
                    },
                },
            },
        }
    end,
}
