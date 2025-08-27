local wrap_schedule = require('utils').wrap_schedule
local Helpers = require('avante.llm_tools.helpers')
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

local mail_script = [[
tell application "Mail"
	set unreadMsgs to (every message of inbox whose read status is false)
end tell

set outText to ""
repeat with m in unreadMsgs
	tell application "Mail"
		set outText to outText & "-----" & linefeed
		set outText to outText & "Subject: " & (subject of m) & linefeed
		set outText to outText & "From: " & (sender of m) & linefeed
		set outText to outText & "Date: " & ((date received of m) as text) & linefeed
		set outText to outText & "Message-ID: " & (message id of m) & linefeed & linefeed
		set outText to outText & (content of m) & linefeed & linefeed
	end tell
end repeat
return outText
]]

function M.applescript_tool()
    return {
        name = 'applescript',
        description = 'Execute AppleScript code on macOS',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'script',
                    description = 'AppleScript code to execute',
                    type = 'string',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Output from the AppleScript execution',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the script failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(params, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            if not params.script then
                on_complete(false, 'script parameter is required')
                return
            end

            -- Check if running on macOS
            if vim.fn.has('mac') == 0 then
                on_complete(false, 'AppleScript is only available on macOS')
                return
            end

            -- Sanitize and prepare the script
            local script = params.script:gsub('"', '\\"')
            local description = 'AppleScript execution'

            on_log(
                '🍎 Executing AppleScript: '
                    .. params.script:sub(1, 100)
                    .. (string.len(params.script) > 100 and '...' or '')
            )

            Helpers.confirm(
                'Are you sure you want to execute this AppleScript?\n\n' .. params.script,
                function(ok, reason)
                    if not ok then
                        on_complete(false, 'User declined ' .. description .. ': ' .. (reason or 'unknown'))
                        return
                    end
                    local full_command = 'osascript -e "' .. script .. '"'

                    vim.system({ 'sh', '-c', full_command }, function(result)
                        if result.code ~= 0 then
                            wrap_schedule(
                                on_complete,
                                false,
                                'AppleScript failed with exit code '
                                    .. result.code
                                    .. ': '
                                    .. (result.stderr or 'unknown error')
                            )
                            return
                        end

                        wrap_schedule(on_complete, result.stdout or '')
                    end)
                end
            )
        end,
    }
end

function M.mail_tool()
    return {
        name = 'apple_mail',
        description = 'Fetch Unread emails',
        param = {
            type = 'table',
            fields = {
                {
                    name = 'placeholder',
                    description = "Avante doesn't support empty inputs/objects so this is here. Fill with anything",
                    type = 'boolean',
                    required = true,
                },
            },
        },
        returns = {
            {
                name = 'output',
                description = 'Output from the AppleScript execution',
                type = 'string',
            },
            {
                name = 'error',
                description = 'Error message if the script failed',
                type = 'string',
                optional = true,
            },
        },
        func = function(_, opts)
            local on_log = opts.on_log
            local on_complete = opts.on_complete

            on_log('📧 Getting unread emails')

            -- Check if running on macOS
            if vim.fn.has('mac') == 0 then
                on_complete(false, 'AppleScript is only available on macOS')
                return
            end

            local cmd = { 'osascript', '-e', mail_script }

            vim.system(cmd, function(result)
                if result.code ~= 0 then
                    wrap_schedule(
                        on_complete,
                        false,
                        'AppleScript failed with exit code '
                            .. result.code
                            .. ': '
                            .. (result.stderr or 'unknown error')
                    )
                    return
                end

                wrap_schedule(on_complete, result.stdout or '')
            end)
        end,
    }
end

return M
