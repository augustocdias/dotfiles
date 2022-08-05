return {
    setup = function()
        require('nvim-dap-virtual-text').setup({
            all_frames = true,
        })
        require('dapui').setup()
    end,
}
