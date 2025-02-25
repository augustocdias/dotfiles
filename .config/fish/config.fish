if status is-interactive
    # Commands to run in interactive sessions can go here
end

ulimit -n unlimited

set -xg SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

test -e {$HOME}/.fish_variables; and source {$HOME}/.fish_variables

# pnpm
set -gx PNPM_HOME /Users/augusto/Library/pnpm
set -gx PATH "$PNPM_HOME" $PATH

# warmup so ssh will work at first try
gpg --card-status 2>/dev/null 1>/dev/null

tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Slanted --powerline_prompt_heads=Slanted --powerline_prompt_tails=Slanted --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Solid --powerline_right_prompt_frame=No --prompt_connection_andor_frame_color=Darkest --prompt_spacing=Sparse --icons='Many icons' --transient=Yes
