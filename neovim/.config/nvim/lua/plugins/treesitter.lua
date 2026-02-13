return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = function()
            require('nvim-treesitter')
                .install({
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
                })
                :wait(300000)
        end,
        lazy = false,
    }, -- enhancements in highlighting and virtual text
    {
        'nvim-treesitter/nvim-treesitter-textobjects', -- adds treesitter based text objects
        branch = 'main',
        lazy = false,
        init = function()
            vim.g.no_plugin_maps = true
        end,
        opts = {
            select = {
                lookahead = true,
            },
        },
        keys = {
            {
                'au',
                function()
                    require('nvim-treesitter-textobjects.select').select_textobject('@comment.outer')
                end,
                mode = { 'x', 'o' },
                desc = 'Select Treesitter Textobjects - Comment Outer',
                noremap = true,
            },
            {
                'iu',
                function()
                    require('nvim-treesitter-textobjects.select').select_textobject('@comment.inner')
                end,
                mode = { 'x', 'o' },
                desc = 'Select Treesitter Textobjects - Comment Inner',
                noremap = true,
            },
            {
                'af',
                function()
                    require('nvim-treesitter-textobjects.select').select_textobject('@function.outer')
                end,
                mode = { 'x', 'o' },
                desc = 'Select Treesitter Textobjects - Function Outer',
                noremap = true,
            },
            {
                'if',
                function()
                    require('nvim-treesitter-textobjects.select').select_textobject('@function.inner')
                end,
                mode = { 'x', 'o' },
                desc = 'Select Treesitter Textobjects - Function Inner',
                noremap = true,
            },
            {
                'ac',
                function()
                    require('nvim-treesitter-textobjects.select').select_textobject('@class.outer')
                end,
                mode = { 'x', 'o' },
                desc = 'Select Treesitter Textobjects - Class Outer',
                noremap = true,
            },
            {
                'ic',
                function()
                    require('nvim-treesitter-textobjects.select').select_textobject('@class.inner')
                end,
                mode = { 'x', 'o' },
                desc = 'Select Treesitter Textobjects - Class Inner',
                noremap = true,
            },
            {
                'ab',
                function()
                    require('nvim-treesitter-textobjects.select').select_textobject('@block.outer')
                end,
                mode = { 'x', 'o' },
                desc = 'Select Treesitter Textobjects - Block Outer',
                noremap = true,
            },
            {
                'ib',
                function()
                    require('nvim-treesitter-textobjects.select').select_textobject('@block.inner')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Select Treesitter Textobjects - Block Inner',
                noremap = true,
            },
            {
                '[f',
                function()
                    require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Move Treesitter Textobjects - Function Outer',
                noremap = true,
            },
            {
                ']f',
                function()
                    require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Move Treesitter Textobjects - Function Outer',
                noremap = true,
            },
            {
                ']F',
                function()
                    require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Move Treesitter Textobjects - Function Outer',
                noremap = true,
            },
            {
                ']F',
                function()
                    require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Move Treesitter Textobjects - Function Outer',
                noremap = true,
            },
            {
                '[c',
                function()
                    require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Move Treesitter Textobjects - Class Outer',
                noremap = true,
            },
            {
                ']c',
                function()
                    require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Move Treesitter Textobjects - Class Outer',
                noremap = true,
            },
            {
                ']C',
                function()
                    require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Move Treesitter Textobjects - Class Outer',
                noremap = true,
            },
            {
                ']C',
                function()
                    require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer')
                end,
                mode = { 'n', 'x', 'o' },
                desc = 'Move Treesitter Textobjects - Class Outer',
                noremap = true,
            },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-context', -- shows context of offscreen block in a float
        lazy = false,
        opts = {
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
        },
    },
}
