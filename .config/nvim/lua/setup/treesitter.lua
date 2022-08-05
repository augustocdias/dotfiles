return {
    setup = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = 'all',
            ignore_install = {
                'phpdoc',
            },
            highlight = {
                enable = true,
                -- add languages not supported by treesitter here
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
                    keymaps = {
                        ['uc'] = '@comment.outer',
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
        -- require('vim.treesitter.query').set_query(
        --     'rust',
        --     'injections',
        --     [[
        -- ((
        --   (raw_string_literal) @constant
        --   (#match? @constant "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).*")
        -- ) @injection.content (#set! injection.language "sql"))
        -- ]]
        -- ) -- inject sql in raw_string_literals
        require('vim.treesitter.query').set_query(
            'rust',
            'injections',
            [[
((
  (line_comment) @constant
) @injection.content (#set! injection.language "markdown_inline"))
]]
        ) -- inject markdown in comments
    end,
}