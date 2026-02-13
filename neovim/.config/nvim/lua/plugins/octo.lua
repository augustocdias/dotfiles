return {
    'pwntester/octo.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    cmd = 'Octo',
    opts = {
        default_merge_method = 'rebase',
        picker = 'snacks',
    },
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
