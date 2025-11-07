local handlers = require('ai.cc.utils')

return handlers.create_tool({
    name = 'apple_script',
    description = 'Execute AppleScript code on macOS',
    properties = {
        script = {
            type = 'string',
            description = 'AppleScript code to execute',
        },
    },
    required = { 'script' },
    ui_log = ' Apple Script',
    func = function(_, schema_params, _, output_handler)
        local script = schema_params.script

        if not script then
            output_handler({ status = 'error', data = 'script parameter is required' })
        end

        -- Check if running on macOS
        if vim.fn.has('mac') == 0 then
            output_handler({ status = 'error', data = 'AppleScript is only available on macOS' })
        end

        -- Execute the script
        local script_escaped = script:gsub('"', '\\"')
        local full_command = 'osascript -e "' .. script_escaped .. '"'

        vim.system({ 'sh', '-c', full_command }, function(result)
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
    prompt = function(self)
        local script_escaped = self.args.script:gsub('"', '\\"')
        return 'Are you sure you want to run: ' .. script_escaped .. '?'
    end,
    system_prompt = [[Execute arbitrary AppleScript code on macOS. This tool provides direct access to macOS automation and application scripting through AppleScript.

**Use Cases**:
- Automate macOS applications (Mail, Finder, Safari, etc.)
- Control system settings and preferences
- Interact with application windows and UI elements
- Read or manipulate application data
- Execute complex multi-step automation workflows

**Security**: All AppleScript executions require user approval before running. The user will see a preview of the script (first 200 characters) before approving.

**Script Parameter**: Provide the complete AppleScript code as a string. The script should be valid AppleScript syntax and will be executed via `osascript -e`.

**Examples of what you can do**:
- Get information from applications
- Control media playback
- Manipulate files and folders
- Send emails or messages
- Create reminders or calendar events
- Control window positions and sizes

Only works on macOS systems. All operations require explicit user approval for security.]],
})
