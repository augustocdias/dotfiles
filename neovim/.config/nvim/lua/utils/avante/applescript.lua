local wrap_schedule = require('utils').wrap_schedule
local Helpers = require('avante.llm_tools.helpers')
local Base = require('avante.llm_tools.base')

local M = setmetatable({}, Base)

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

            if on_log then
                on_log(
                    'Executing AppleScript: '
                        .. params.script:sub(1, 100)
                        .. (string.len(params.script) > 100 and '...' or '')
                )
            end

            local function run_applescript()
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

            -- Always require confirmation for AppleScript execution (security)
            Helpers.confirm(
                'Are you sure you want to execute this AppleScript?\n\n' .. params.script,
                function(ok, reason)
                    if not ok then
                        on_complete(false, 'User declined ' .. description .. ': ' .. (reason or 'unknown'))
                        return
                    end
                    run_applescript()
                end
            )
        end,
    }
end

return M
