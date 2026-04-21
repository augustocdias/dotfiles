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

    --- Focus an upcoming edit location: display file in the rightmost window,
    --- scroll viewport to center on the edit region, and briefly highlight the
    --- lines being edited. Does not move the user's cursor or change focus.
    --- The highlight auto-clears after 2 seconds so subsequent edits get fresh cues.
    ---@param filepath string Path to the file (relative to cwd or absolute)
    ---@param start_line number First line of the edit region (1-indexed)
    ---@param end_line? number Last line of the edit region (defaults to start_line)
    focus_edit = function(filepath, start_line, end_line)
        end_line = end_line or start_line
        local wins = vim.api.nvim_tabpage_list_wins(0)
        -- Filter out floating windows (overlays, popups, completion menus, etc.).
        -- A floating window has a non-empty `relative` field in its config.
        wins = vim.tbl_filter(function(w)
            return vim.api.nvim_win_get_config(w).relative == ''
        end, wins)
        local rightmost_win = wins[1]
        local max_col = -1
        for _, w in ipairs(wins) do
            local col = vim.api.nvim_win_get_position(w)[2]
            if col > max_col then
                max_col = col
                rightmost_win = w
            end
        end
        vim.cmd('badd ' .. vim.fn.fnameescape(filepath))
        local buf = vim.fn.bufnr(filepath)
        vim.api.nvim_win_set_buf(rightmost_win, buf)
        vim.api.nvim_win_call(rightmost_win, function()
            -- Position start_line near the top of the viewport (with ~5 lines of
            -- context above) so large edit ranges stay visible below.
            local top = math.max(1, start_line - 5)
            vim.api.nvim_win_set_cursor(rightmost_win, { top, 0 })
            vim.cmd('normal! zt')
            vim.api.nvim_win_set_cursor(rightmost_win, { start_line, 0 })
        end)
        local ns = vim.api.nvim_create_namespace('focus_edit')
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        vim.hl.range(buf, ns, 'DiffAdd', { start_line - 1, 0 }, { end_line - 1, -1 })
        vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
            end
        end, 2000)
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
