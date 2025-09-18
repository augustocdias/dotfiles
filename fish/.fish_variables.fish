set -gx BAT_THEME Catppuccin Mocha
set -gx FZF_ALT_C_COMMAND "fd --type d"
set -gx FZF_DEFAULT_COMMAND "rg --files --no-ignore-exclude"
set -gx FZF_DEFAULT_OPTS "--layout=reverse --inline-info --multi \
--preview=\"bat --style=numbers --color=always {} 2>/dev/null || echo 'Not a file' | head -300\" \
--preview-window=\"right:wrap\" --bind='f3:execute(bat --paging always \
--pager \"less -R\" {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo{+} | pbcopy)' \
--color=bg+:#CCD0DA,bg:#EFF1F5,spinner:#DC8A78,hl:#D20F39 \
--color=fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78 \
--color=marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39 \
--color=selected-bg:#BCC0CC \
--color=border:#9CA0B0,label:#4C4F69"
set -gx FZF_PREVIEW_DIR_CMD eza
set -gx GITHUB_USER augustocdias
set -gx GOPATH "$HOME/.go"
set -gx SEARXNG_API_URL https://searx.oloke.xyz/

fish_add_path -g $HOME/.local/share/bob/nvim-bin/
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/.cargo/bin/
fish_add_path -g /opt/homebrew/bin
fish_add_path -g /opt/homebrew/sbin
fish_add_path -g $GOPATH/bin
