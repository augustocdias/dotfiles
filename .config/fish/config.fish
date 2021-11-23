if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -xg SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)

test -e {$HOME}/.iterm2_shell_integration.fish; and source {$HOME}/.iterm2_shell_integration.fish
test -e {$HOME}/.fish_variables; and source {$HOME}/.fish_variables
