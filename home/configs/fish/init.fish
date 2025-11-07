# Load GPG-encrypted secrets
if test -f $XDG_RUNTIME_DIR/env-secrets.fish
    source $XDG_RUNTIME_DIR/env-secrets.fish
end

# Set SSH to use GPG agent
set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

# FZF configuration with Catppuccin Mocha theme
set -gx FZF_DEFAULT_OPTS "--layout=reverse --inline-info --multi --preview=\"bat --style=numbers --color=always {} 2>/dev/null || echo 'Not a file' | head -300\" --preview-window=\"right:wrap\" --bind='f3:execute(bat --paging always --pager \"less -R\" {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo{+} | pbcopy)' --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 --color=selected-bg:#45475A --color=border:#6C7086,label:#CDD6F4"

# Initialize tools
fzf --fish | source
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
