local handlers = require('ai.cc.utils')

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

return handlers.create_tool({
    name = 'apple_mail',
    description = 'Fetch unread emails from Apple Mail',
    func = function(_, _, _, output_handler)
        if vim.fn.has('mac') == 0 then
            output_handler({ status = 'error', data = 'AppleScript is only available on macOS' })
        end

        local cmd = { 'osascript', '-e', mail_script }

        vim.system(cmd, function(result)
            vim.schedule(function()
                if result.code ~= 0 then
                    output_handler({
                        status = 'error',
                        data = 'AppleScript failed with exit code '
                            .. result.code
                            .. ': '
                            .. (result.stderr or 'unknown error'),
                    })
                else
                    output_handler({ status = 'success', data = result.stdout or '' })
                end
            end)
        end)
    end,
    properties = {},
    ui_log = ' Apple Mail',
    system_prompt = [[Fetch unread emails from Apple Mail application on macOS. This is a specialized read-only tool for retrieving email information.

**What it returns**:
For each unread email in the inbox, you'll get:
- Subject line
- Sender email address
- Date received
- Message-ID (unique identifier)
- Full email content/body

**Use Cases**:
- Check for new emails without opening Mail.app
- Get email content for processing or analysis
- Monitor inbox for specific messages
- Extract information from recent emails
- Build email summaries or reports

This tool is read-only and does not modify any emails or mark them as read. It simply queries the Mail application for unread messages in the inbox. Only works on macOS systems with Mail.app configured.]],
})
