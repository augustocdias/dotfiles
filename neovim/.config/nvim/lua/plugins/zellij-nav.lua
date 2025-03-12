-- integrates focus on windows with zellij panes
return {
    'swaits/zellij-nav.nvim',
    lazy = true,
    event = 'VeryLazy',
    config = true,
    cond = os.getenv('ZELLIJ') ~= nil,
}
