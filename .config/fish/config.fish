if status is-interactive
    # Commands to run in interactive sessions can go here
end

ulimit -n unlimited

set -xg SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

test -e {$HOME}/.iterm2_shell_integration.fish; and source {$HOME}/.iterm2_shell_integration.fish
test -e {$HOME}/.fish_variables; and source {$HOME}/.fish_variables

# pnpm
set -gx PNPM_HOME /Users/augusto/Library/pnpm
set -gx PATH "$PNPM_HOME" $PATH
# pnpm endsource /Users/augusto/.config/op/plugins.sh
source /Users/augusto/.config/op/plugins.sh
