set -gx BAT_THEME Catppuccin Mocha
set -gx FZF_ALT_C_COMMAND "fd --type d"
set -gx FZF_DEFAULT_COMMAND "rg --files --no-ignore-exclude"
set -gx FZF_DEFAULT_OPTS "--layout=reverse --inline-info --multi --preview=\"bat --style=numbers --color=always {} 2>/dev/null || echo 'Not a file' | head -300\" --preview-window=\"right:wrap\" --bind='f3:execute(bat --paging always --pager \"less -R\" {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo{+} | pbcopy)' --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=selected-bg:#45475a"
set -gx FZF_PREVIEW_DIR_CMD eza
set -gx GITHUB_USER augustocdias
set -gx COLIMA_HOME "$HOME/.colima"
set -gx DOCKER_HOST "unix://$COLIMA_HOME/default/docker.sock"
set -gx GOPATH "$HOME/.go"

fish_add_path -g $HOME/.local/share/bob/nvim-bin/
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/.cargo/bin/
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path $GOPATH/bin
