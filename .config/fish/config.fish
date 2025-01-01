if status is-interactive
    # Commands to run in interactive sessions can go here
end

ulimit -n unlimited

set -xg SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

test -e {$HOME}/.fish_variables; and source {$HOME}/.fish_variables

# pnpm
set -gx PNPM_HOME /Users/augusto/Library/pnpm
set -gx PATH "$PNPM_HOME" $PATH
