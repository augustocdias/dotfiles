ulimit -n unlimited

set -xg SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

test -e {$HOME}/.fish_variables.fish; and source {$HOME}/.fish_variables.fish
test -e {$HOME}/.fish_secret_variables.fish; and source {$HOME}/.fish_secret_variables.fish

# warmup so ssh will work at first try
gpg --card-status 2>/dev/null 1>/dev/null

# fzf
fzf --fish | source
# zoxide
zoxide init fish | source

fish_vi_key_bindings

alias afk='open -a /System/Library/CoreServices/ScreenSaverEngine.app'

# uv
fish_add_path "/Users/augusto/.local/bin"

function starship_transient_prompt_func
    echo \n "  "
end

function starship_transient_rprompt_func
    starship module cmd_duration
    starship module time
end

starship init fish | source
enable_transience
