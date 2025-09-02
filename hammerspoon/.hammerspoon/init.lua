require('hs.ipc')

local json = require('hs.json')
local slackToken = os.getenv('SLACK_TOKEN')
local home = os.getenv('HOME')

-- Shell helper
local function run(cmd)
    local h = io.popen(cmd)
    if not h then
        return nil
    end
    local res = h:read('*a')
    h:close()
    return res
end

-- Determine active Neovim socket based on Zellij session
local function getActiveZellij()
    local out = run('zellij list-sessions -n')
    if not out then
        return nil
    end
    for line in out:gmatch('[^\r\n]+') do
        if line:match('%(current%)') then
            return line:match('^(%S+)')
        end
    end
    return nil
end

local function getNvimSocket()
    local session = getActiveZellij()
    return home .. '/.cache/nvim/server-' .. (session or 'detached') .. '.pipe'
end

-- Run command if Neovim is listening
local function forwardToNvim(msg)
    local sock = getNvimSocket()
    if not sock or io.open(sock) == nil then
        return
    end
    local lua = string.format(":lua require('avante.api').ask([[%s]])<CR>", msg)
    local cmd = string.format("nvim --server %s --remote-send '%s'", sock, lua)
    run(cmd)
end

-- Table to store scheduled URL openings
scheduledUrls = {}
scheduledTimers = {}

-- Function to open URL in default browser
function openUrl(url)
    hs.urlevent.openURL(url)
    hs.notify
        .new({
            title = 'Meeting Started',
            informativeText = 'Opening: ' .. url,
            soundName = 'Glass',
        })
        :send()
    return 'URL opened: ' .. url
end

-- Function to schedule URL opening at specific time
function scheduleUrl(url, datetime, title)
    title = title or 'Meeting'

    -- Parse datetime (expected format: "2025-08-25T14:30:00")
    local year, month, day, hour, min, sec = datetime:match('(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d):(%d%d)')

    if not year then
        return 'Error: Invalid datetime format. Use: YYYY-MM-DDTHH:MM:SS'
    end

    -- Create target time
    local targetTime = os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec) or 0,
    })

    local currentTime = os.time()
    local delay = targetTime - currentTime

    if delay <= 0 then
        hs.notify
            .new({
                title = 'Schedule Warning',
                informativeText = 'Time has already passed. Opening immediately.',
                soundName = 'Basso',
            })
            :send()
        openUrl(url)
        return 'Warning: Time passed, opened immediately'
    end

    -- Create unique ID for this scheduled item
    local scheduleId = url .. '_' .. datetime

    -- Cancel existing timer if it exists
    if scheduledTimers[scheduleId] then
        scheduledTimers[scheduleId]:stop()
    end

    -- Create new timer
    local timer = hs.timer.doAfter(delay, function()
        openUrl(url)
        scheduledUrls[scheduleId] = nil
        scheduledTimers[scheduleId] = nil
    end)

    -- Store the schedule
    scheduledUrls[scheduleId] = {
        url = url,
        datetime = datetime,
        title = title,
        targetTime = targetTime,
    }
    scheduledTimers[scheduleId] = timer

    -- Confirmation notification
    local timeStr = os.date('%H:%M', targetTime)
    hs.notify
        .new({
            title = 'Meeting Scheduled',
            informativeText = string.format('%s at %s', title, timeStr),
            soundName = 'Hero',
        })
        :send()

    return 'Scheduled: ' .. title .. ' at ' .. timeStr
end

-- Function to list scheduled URLs
function listScheduledUrls()
    local count = 0
    local message = 'Scheduled Meetings:\n'

    for _, schedule in pairs(scheduledUrls) do
        count = count + 1
        local timeStr = os.date('%H:%M', schedule.targetTime)
        message = message .. string.format('%d. %s at %s: %s\n', count, schedule.title, timeStr, schedule.url)
    end

    if count == 0 then
        message = 'No meetings scheduled.'
    end

    return message
end

-- Function to cancel scheduled URL
function cancelScheduledUrl(url, datetime)
    local scheduleId = url .. '_' .. datetime

    if scheduledTimers[scheduleId] then
        scheduledTimers[scheduleId]:stop()
        scheduledTimers[scheduleId] = nil
        scheduledUrls[scheduleId] = nil

        hs.notify
            .new({
                title = 'Meeting Cancelled',
                informativeText = 'Scheduled meeting cancelled',
                soundName = 'Basso',
            })
            :send()

        return 'Meeting cancelled successfully'
    end

    return 'Meeting not found'
end

-- Function to cancel all scheduled URLs
function cancelAllScheduledUrls()
    local count = 0
    for scheduleId, timer in pairs(scheduledTimers) do
        timer:stop()
        count = count + 1
    end

    scheduledTimers = {}
    scheduledUrls = {}

    hs.notify
        .new({
            title = 'All Meetings Cancelled',
            informativeText = string.format('Cancelled %d scheduled meetings', count),
            soundName = 'Basso',
        })
        :send()

    return 'Cancelled ' .. count .. ' scheduled meetings'
end
