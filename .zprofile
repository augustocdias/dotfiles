export PATH="$HOME/.cargo/bin:/usr/local/lib/ruby/gems/2.5.0/bin:/usr/local/sbin:$PATH"
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/library"

export FZF_DEFAULT_OPTS="--layout=reverse --inline-info --multi --preview='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -300' --preview-window='right:wrap' --bind='f3:execute(bat --paging always --pager \"less -R\" {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo{+} | pbcopy)'"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-exclude --ignore-file ~/.config/nvim/.fzf-ignore'
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="fd $FD_OPTIONS"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


export PATH="$HOME/.cargo/bin:$PATH"

# config gpg
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=`gpgconf --list-dirs agent-ssh-socket`
