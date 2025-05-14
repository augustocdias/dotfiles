return {
    'pwntester/octo.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
    },
    cmd = 'Octo',
    opts = {
        default_merge_method = 'rebase',
        picker = 'snacks',
    },
}
