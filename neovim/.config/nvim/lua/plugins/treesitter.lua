return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = 'VeryLazy',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',     -- adds treesitter based text objects
            { 'nvim-treesitter/playground', enabled = false }, -- TS PLayground for creating queries
            'nvim-treesitter/nvim-treesitter-context',         -- shows context of offscreen block in a float
        },
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    'bash',
                    'c',
                    'comment',
                    'cpp',
                    'c_sharp',
                    'css',
                    'diff',
                    'dockerfile',
                    'dtd',
                    'editorconfig',
                    'fish',
                    'gdscript',
                    'godot_resource',
                    'gdshader',
                    'git_config',
                    'git_rebase',
                    'gitattributes',
                    'gitcommit',
                    'gitignore',
                    'html',
                    'java',
                    'javascript',
                    'jsdoc',
                    'json',
                    'json5',
                    'kdl',
                    'kotlin',
                    'lua',
                    'luadoc',
                    'markdown',
                    'markdown_inline',
                    'norg',
                    'python',
                    'query',
                    'regex',
                    'rust',
                    'sql',
                    'swift',
                    'toml',
                    'typescript',
                    'vim',
                    'vimdoc',
                    'yaml',
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true,
                    disable = {
                        'rust',
                        'python',
                    },
                },
                matchup = {
                    enable = true,
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ['au'] = '@comment.outer',
                            ['iu'] = '@comment.inner',
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ac'] = '@class.outer',
                            ['ic'] = '@class.inner',
                            ['ab'] = '@block.outer',
                            ['ib'] = '@block.inner',
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ['[f'] = '@function.outer',
                            ['[c'] = { query = '@class.outer', desc = 'Next class start' },
                        },
                        goto_next_end = {
                            [']f'] = '@function.outer',
                            [']c'] = '@class.outer',
                        },
                        goto_previous_start = {
                            ['[F'] = '@function.outer',
                            ['[C'] = '@class.outer',
                        },
                        goto_previous_end = {
                            [']F'] = '@function.outer',
                            [']C'] = '@class.outer',
                        },
                    },
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<CR>',
                        scope_incremental = '<CR>',
                        node_incremental = '<TAB>',
                        node_decremental = '<S-TAB>',
                    },
                },
            })

            require('treesitter-context').setup({
                enable = true,
                max_lines = 3,
                mode = 'topline',
                patterns = {
                    default = {
                        'class',
                        'function',
                        'method',
                        'for',
                        'while',
                        'if',
                        'switch',
                        'case',
                    },
                    rust = {
                        'impl_item',
                        'struct',
                        'enum',
                    },
                    json = {
                        'pair',
                    },
                    yaml = {
                        'block_mapping_pair',
                    },
                },
            })
        end,
    }, -- enhancements in highlighting and virtual text
}
