return {
    'yetone/avante.nvim',
    build = function()
        if vim.fn.has('win32') == 1 then
            return 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
        else
            return 'make'
        end
    end,
    event = 'VeryLazy',
    version = false, -- Never set this value to "*"! Never!
    cmd = {
        'AvanteAsk',
        'AvanteChat',
        'AvanteBuild',
        'AvanteChatNew',
        'AvanteHistory',
        'AvanteClear',
        'AvanteEdit',
        'AvanteFocus',
        'AvanteRefresh',
        'AvanteStop',
        'AvanteSwitchProvider',
        'AvanteShowRepoMap',
        'AvanteToggle',
        'AvanteModels',
        'AvanteSwitchSelectorProvider',
    },
    opts = {
        provider = 'gemini',
        providers = {
            gemini = {
                model = 'gemini-2.5-pro',
            },
        },
        auto_suggestions_provider = nil,
        web_search_engine = {
            provider = 'google',
        },
    },
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-tree/nvim-web-devicons',
        -- 'github/copilot.vim', -- disable after setup
    },
}
