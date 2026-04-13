#!/usr/bin/env fish
# Stop screen recording and open the resulting file with dragon-drop

set -l recordings_dir ~/videos/recordings

dms ipc call screenRecorder stopRecording

# Wait for the file to be finalized
sleep 2

set -l recording (ls -t $recordings_dir/*.mp4 2>/dev/null | head -1)

if test -n "$recording"
    dragon-drop --and-exit --on-top --all $recording
end
