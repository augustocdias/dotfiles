# Load GPG-encrypted secrets
if test -f $XDG_RUNTIME_DIR/env-secrets.fish
    source $XDG_RUNTIME_DIR/env-secrets.fish
end

# Set SSH to use GPG agent
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

zoxide init fish | source

# Vi key bindings
fish_vi_key_bindings

# Starship transient prompt functions
function starship_transient_prompt_func
    echo \n
    string pad --right --width=$COLUMNS --char='.' "."
    echo "󰞷  "
end

function starship_transient_rprompt_func
    starship module time
end

# Initialize starship
starship init fish | source
enable_transience
