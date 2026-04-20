return {
    noice_status_color = function(flavour)
        if vim.g.theme == 'catppuccin' then
            return require('catppuccin.palettes').get_palette(flavour)['teal']
        else
            return require('tokyonight.colors').setup({ style = flavour }).teal
        end
    end,

    command_status = function(color)
        return {
            function()
                return require('noice').api.status.command.get()
            end,
            cond = function()
                return require('noice').api.status.command.has()
            end,
            color = { fg = color },
        }
    end,

    -- Given a Rust target triple, return a descriptive hostname
    describe_host = function(target)
        local mappings = {
            ['x86_64-apple-darwin'] = ' Mac (Intel)',
            ['aarch64-apple-darwin'] = ' Mac (Apple Silicon)',
            ['x86_64-unknown-linux-gnu'] = ' Linux (x86_64)',
            ['aarch64-unknown-linux-gnu'] = ' Linux (ARM64)',
            ['x86_64-pc-windows-msvc'] = '  Windows (x86_64)',
            ['i686-pc-windows-msvc'] = '󰨡  Windows (32-bit)',
            ['x86_64-pc-windows-gnu'] = '  Windows (x86_64)',
            ['i686-pc-windows-gnu'] = '󰨡  Windows (32-bit)',
        }

        return mappings[target] or ('Unknown Host (' .. target .. ')')
    end,

    -- Returns rust's host target triple
    get_host_target = function()
        local cmd = "cargo -vV | grep 'host' | cut -d' ' -f2"
        local host = vim.fn.system(cmd):gsub('%s+', '') -- remove trailing newline/whitespace

        if vim.v.shell_error ~= 0 or host == '' then
            return nil, 'Failed to get cargo host'
        end

        return host
    end,

    --- Display a file in the rightmost window without changing focus.
    --- Optionally positions the viewport at the given line.
    ---@param filepath string Path to the file (relative to cwd or absolute)
    ---@param line? number Line number to center the viewport on
    show_in_rightmost = function(filepath, line)
        local wins = vim.api.nvim_tabpage_list_wins(0)
        local rightmost_win = wins[1]
        local max_col = 0
        for _, w in ipairs(wins) do
            local pos = vim.api.nvim_win_get_position(w)
            if pos[2] > max_col then
                max_col = pos[2]
                rightmost_win = w
            end
        end
        vim.cmd('badd ' .. vim.fn.fnameescape(filepath))
        local buf = vim.fn.bufnr(filepath)
        vim.api.nvim_win_set_buf(rightmost_win, buf)
        if line then
            vim.api.nvim_win_call(rightmost_win, function()
                vim.api.nvim_win_set_cursor(rightmost_win, { line, 0 })
                vim.cmd('normal! zz')
            end)
        end
    end,

    --- Save a specific buffer by filepath without changing focus.
    ---@param filepath string Path to the file
    save_buf = function(filepath)
        local buf = vim.fn.bufnr(filepath)
        if buf ~= -1 then
            vim.api.nvim_buf_call(buf, function()
                vim.cmd('w')
            end)
        end
    end,

    -- Start a neovim server on the given pipe path, reclaiming stale sockets.
    -- If another neovim is already listening on the pipe, this is a no-op
    -- (the first instance keeps ownership). If the socket file exists but no
    -- one is listening, it's stale and gets cleaned up before creating a new one.
    start_server = function(pipepath)
        local alive = false
        if vim.uv.fs_stat(pipepath) then
            local ok, conn = pcall(vim.fn.sockconnect, 'pipe', pipepath)
            if ok and conn and conn > 0 then
                alive = true
                vim.fn.chanclose(conn)
            end
        end
        if not alive then
            vim.fn.delete(pipepath)
            vim.fn.serverstart(pipepath)
        end
    end,
}
