local M = {}

-- Configuration
local config = {
    -- Log directory
    log_dir = vim.fn.stdpath('cache') .. '/logs',
    -- Maximum log file size in bytes (10MB)
    max_file_size = 10 * 1024 * 1024,
    -- Number of rotated log files to keep
    max_files = 5,
    -- Default log level (DEBUG, INFO, WARN, ERROR)
    level = 'INFO',
    -- Whether to also print to console for development
    console_output = false,
    -- Date format for log entries
    date_format = '%Y-%m-%d %H:%M:%S',
}

-- Log levels with numeric values for comparison
local levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

-- Ensure log directory exists
local function ensure_log_dir()
    local log_dir = config.log_dir
    if vim.fn.isdirectory(log_dir) == 0 then
        vim.fn.mkdir(log_dir, 'p')
    end
end

-- Get log file path for a specific logger name
local function get_log_path(name)
    return config.log_dir .. '/' .. name .. '.log'
end

-- Rotate log file if it's too large
local function rotate_log_if_needed(log_path)
    local stat = vim.uv.fs_stat(log_path)
    if not stat or stat.size < config.max_file_size then
        return
    end

    -- Rotate existing files
    for i = config.max_files - 1, 1, -1 do
        local old_file = log_path .. '.' .. i
        local new_file = log_path .. '.' .. (i + 1)

        if vim.fn.filereadable(old_file) == 1 then
            vim.fn.rename(old_file, new_file)
        end
    end

    -- Move current log to .1
    if vim.fn.filereadable(log_path) == 1 then
        vim.fn.rename(log_path, log_path .. '.1')
    end
end

-- Write log entry to file
local function write_log(log_path, level, message, context)
    rotate_log_if_needed(log_path)

    local timestamp = os.date(config.date_format)
    local context_str = context and (' [' .. context .. ']') or ''
    local log_line = string.format('[%s] %s%s: %s\n', timestamp, level, context_str, message)

    local file = io.open(log_path, 'a')
    if file then
        file:write(log_line)
        file:close()
    end

    -- Also print to console if enabled
    if config.console_output then
        print(log_line:sub(1, -2)) -- Remove trailing newline
    end
end

-- Check if message should be logged based on current level
local function should_log(level)
    return levels[level] >= levels[config.level]
end

-- Create a logger instance
function M.new(name)
    ensure_log_dir()
    local log_path = get_log_path(name)

    local logger = {}

    function logger.debug(message, context)
        if should_log('DEBUG') then
            write_log(log_path, 'DEBUG', tostring(message), context)
        end
    end

    function logger.info(message, context)
        if should_log('INFO') then
            write_log(log_path, 'INFO', tostring(message), context)
        end
    end

    function logger.warn(message, context)
        if should_log('WARN') then
            write_log(log_path, 'WARN', tostring(message), context)
        end
    end

    function logger.error(message, context)
        if should_log('ERROR') then
            write_log(log_path, 'ERROR', tostring(message), context)
        end
    end

    -- Special method for stderr output that might not be actual errors
    function logger.stderr(message, context, is_error)
        is_error = is_error or false

        -- Try to determine if this is actually an error or just regular output
        local msg_lower = string.lower(tostring(message))
        local likely_error = is_error
            or string.match(msg_lower, 'error')
            or string.match(msg_lower, 'failed')
            or string.match(msg_lower, 'exception')
            or string.match(msg_lower, 'fatal')

        if likely_error then
            logger.error('[STDERR] ' .. tostring(message), context)
        else
            logger.info('[STDERR] ' .. tostring(message), context)
        end
    end

    -- Method to log with custom level
    function logger.log(level, message, context)
        level = string.upper(level)
        if levels[level] and should_log(level) then
            write_log(log_path, level, tostring(message), context)
        end
    end

    return logger
end

-- Configure the logging system
function M.setup(opts)
    config = vim.tbl_extend('force', config, opts or {})
    ensure_log_dir()

    local complete_log_files = function()
        -- Return available log files
        local files = vim.fn.glob(config.log_dir .. '/*.log', false, true)
        local names = {}
        for _, file in ipairs(files) do
            local name = vim.fn.fnamemodify(file, ':t:r')
            table.insert(names, name)
        end
        return names
    end

    vim.api.nvim_create_user_command('Logger', function(options)
        local name = options and options.args ~= '' and options.args or 'nvim'
        M.view_logs(name)
    end, {
        nargs = '?',
        desc = 'View MCP logs',
        complete = complete_log_files,
    })

    vim.api.nvim_create_user_command('LoggerTail', function(options)
        local args = vim.split(options.args, ' ')
        local name = args[1] or 'nvim'
        local lines = tonumber(args[2]) or 50
        M.tail_logs(name, lines)
    end, {
        nargs = '*',
        desc = 'Tail logs (follow new entries)',
        complete = complete_log_files,
    })

    vim.api.nvim_create_user_command('LoggerCleanup', function()
        M.cleanup()
        vim.notify('Cleaned up old log files', vim.log.levels.INFO)
    end, {
        desc = 'Clean up old log files',
    })
end

-- Get current configuration
function M.get_config()
    return vim.deepcopy(config)
end

-- Clean old log files
function M.cleanup()
    ensure_log_dir()
    local files = vim.fn.glob(config.log_dir .. '/*.log*', false, true)

    for _, file in ipairs(files) do
        local stat = vim.uv.fs_stat(file)
        if stat then
            -- Remove files older than 30 days
            local age_days = (os.time() - stat.mtime.sec) / (24 * 60 * 60)
            if age_days > 30 then
                vim.fn.delete(file)
            end
        end
    end
end

-- View logs in a new buffer
function M.view_logs(name)
    name = name or 'default'
    local log_path = get_log_path(name)

    if vim.fn.filereadable(log_path) == 0 then
        vim.notify('No log file found: ' .. log_path, vim.log.levels.WARN)
        return
    end

    -- Open log file in a new buffer
    vim.cmd('tabnew ' .. log_path)
    vim.bo.readonly = true
    vim.bo.modifiable = false

    -- Go to end of file
    vim.cmd('normal! G')
end

-- Tail logs (follow new entries)
function M.tail_logs(name, lines)
    name = name or 'default'
    lines = lines or 50
    local log_path = get_log_path(name)

    if vim.fn.filereadable(log_path) == 0 then
        vim.notify('No log file found: ' .. log_path, vim.log.levels.WARN)
        return
    end

    -- Create a new buffer for tailing
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'Log Tail: ' .. name)

    -- Open in a split
    local win_id = vim.api.nvim_open_win(buf, false, {
        noautocmd = true,
        split = 'below',
    })

    -- Set buffer options
    vim.bo[buf].readonly = true
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = 'log'
    vim.bo[buf].bufhidden = 'hide'
    vim.bo[buf].buftype = 'nofile'

    -- Function to update buffer with latest log entries
    local function update_buffer()
        local cmd = 'tail -n ' .. lines .. ' ' .. vim.fn.shellescape(log_path)
        local result = vim.fn.system(cmd)

        if vim.v.shell_error == 0 then
            local log_lines = vim.split(result, '\n')
            -- Remove empty last line if present
            if log_lines[#log_lines] == '' then
                table.remove(log_lines)
            end

            vim.bo[buf].modifiable = true
            vim.bo[buf].readonly = false
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, log_lines)
            vim.bo[buf].modifiable = false
            vim.bo[buf].readonly = true

            -- Scroll to bottom
            vim.api.nvim_win_set_cursor(win_id, { #log_lines, 0 })
        end
    end

    -- Initial update
    vim.schedule(update_buffer)

    -- Set up auto-refresh every 2 seconds
    local timer = vim.uv.new_timer()
    timer:start(2000, 2000, vim.schedule_wrap(update_buffer))

    vim.keymap.set('n', 'q', function()
        timer:stop()
        timer:close()
        vim.api.nvim_win_close(win_id, true)
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end, {
        buffer = buf,
        silent = true,
        noremap = true,
        desc = 'Close log tail',
    })
end

return M
