ulimit -n unlimited

set -xg SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

test -e {$HOME}/.fish_variables.fish; and source {$HOME}/.fish_variables.fish
test -e {$HOME}/.fish_secret_variables.fish; and source {$HOME}/.fish_secret_variables.fish

# warmup so ssh will work at first try
gpg --card-status 2>/dev/null 1>/dev/null

# fzf
fzf --fish | source

if type -q tide
    tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Slanted --powerline_prompt_heads=Slanted --powerline_prompt_tails=Slanted --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Darkest --prompt_spacing=Sparse --icons='Many icons' --transient=Yes
end

zoxide init fish | source
