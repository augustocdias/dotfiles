set -gx BAT_THEME Catppuccin Mocha
set -gx FZF_ALT_C_COMMAND "fd --type d"
set -gx FZF_DEFAULT_COMMAND "rg --files --no-ignore-exclude"
# tokyonight night
# set -gx FZF_THEME_OPTS " --highlight-line \
#   --info=inline-right \
#   --ansi \
#   --layout=reverse \
#   --border=none \
#   --color=bg+:#283457 \
#   --color=bg:#16161e \
#   --color=border:#27a1b9 \
#   --color=fg:#c0caf5 \
#   --color=gutter:#16161e \
#   --color=header:#ff9e64 \
#   --color=hl+:#2ac3de \
#   --color=hl:#2ac3de \
#   --color=info:#545c7e \
#   --color=marker:#ff007c \
#   --color=pointer:#ff007c \
#   --color=prompt:#2ac3de \
#   --color=query:#c0caf5:regular \
#   --color=scrollbar:#27a1b9 \
#   --color=separator:#ff9e64 \
#   --color=spinner:#ff007c"
# catpuccin latte
# set -gx FZF_THEME_OPTS "--color=bg+:#CCD0DA,bg:#EFF1F5,spinner:#DC8A78,hl:#D20F39 \
# --color=fg:#4C4F69,header:#D20F39,info:#8839EF,pointer:#DC8A78 \
# --color=marker:#7287FD,fg+:#4C4F69,prompt:#8839EF,hl+:#D20F39 \
# --color=selected-bg:#BCC0CC \
# --color=border:#9CA0B0,label:#4C4F69"
# catpuccin mocha
set -Ux FZF_THEME_OPTS "--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
set -gx FZF_DEFAULT_OPTS "--layout=reverse --inline-info --multi \
--preview=\"bat --style=numbers --color=always {} 2>/dev/null || echo 'Not a file' | head -300\" \
--preview-window=\"right:wrap\" --bind='f3:execute(bat --paging always \
--pager \"less -R\" {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo{+} | pbcopy)' \
$FZF_THEME_OPTS"
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
