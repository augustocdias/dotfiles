-- inspired by (and some code from) https://github.com/imjoshnewton/apple-music-nvim
local M = {
    music = {
        _current_track = '',
    },
}

function string.starts_with(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

local function music_command(cmd)
    local command = 'osascript -e "tell application \\"Music\\" to ' .. cmd .. '"'
    vim.fn.system(command)
end

function M.music:listen()
    local trackInfoCmd =
        'osascript -e "tell application \\"Music\\" to get artist of current track & \\" - \\" & name of current track"'
    local timer = vim.loop.new_timer()
    timer:start(
        1000,
        5000,
        vim.schedule_wrap(function()
            local track = vim.fn.system(trackInfoCmd)
            if string.starts_with(track, '58:63') then
                self._current_track = ''
            else
                self._current_track = ' ' .. track:gsub('^%s*(.-)%s*$', '%1')
            end
        end)
    )
end

function M.music:play_pause()
    music_command('playpause')
end

function M.music:next_track()
    music_command('next track')
end

function M.music:previous_track()
    music_command('previous track')
end

function M.music:current_track()
    return self._current_track
end

function M.music:playlists()
    local apple_script = [[
tell application "Music"
    set playlistList to "["
    set allPlaylists to every playlist
    repeat with aPlaylist in allPlaylists
        if length of playlistList > 1 then
            set playlistList to playlistList & ", "
        end if
        set playlistList to playlistList & "\"" & (name of aPlaylist) & "\""
    end repeat
    set playlistList to playlistList & "]"
end tell

return playlistList
    ]]

    local playlists = vim.fn.system("osascript -e '" .. apple_script .. "'")
    local trimmed = playlists:sub(3, -4)
    local results = vim.split(trimmed, '", "')
    vim.inspect(results)
    local items = {}
    for _, v in ipairs(results) do
        table.insert(items, { text = v })
    end

    Snacks.picker.pick({
        source = 'Apple Music ',
        items = items,
        format = 'text',
        preview = 'none',
        confirm = function(picker, item)
            picker:close()
            local play_command = 'play playlist \\"' .. item.text .. '\\"'
            music_command(play_command)
        end,
    })
end

return M
