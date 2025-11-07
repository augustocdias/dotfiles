return {
    'octo',
    cmd = 'Octo',
    after = function()
        require('octo').setup({
        default_merge_method = 'rebase',
        picker = 'snacks',
    })
    end,
    keys = {
        { '<localleader>a', 'rhs', desc = 'Assignee (Octo)', ft = 'octo' },
        { '<localleader>c', 'rhs', desc = 'Comment/Code (Octo)', ft = 'octo' },
        { '<localleader>l', 'rhs', desc = 'Label (Octo)', ft = 'octo' },
        { '<localleader>i', 'rhs', desc = 'Issue (Octo)', ft = 'octo' },
        { '<localleader>r', 'rhs', desc = 'React (Octo)', ft = 'octo' },
        { '<localleader>p', 'rhs', desc = 'PR (Octo)', ft = 'octo' },
        { '<localleader>v', 'rhs', desc = 'Review (Octo)', ft = 'octo' },
    },
}
