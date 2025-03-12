-- Enhances the % and matches for blocks

return {
    'andymass/vim-matchup',
    config = function()
        vim.g.matchup_matchparen_offscreen = { method = 'popup' }
        vim.g.matchup_transmute_enabled = true
    end,
}
