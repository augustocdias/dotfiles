# Personal Settings and Tools

My personal mac os settings and tools

## Brew

Install [brew](https://brew.sh)

To generate the dump: `brew bundle dump`

To install from the bundle: `brew bundle install`

## iTerm2

1. In Preferences->General->Preferences check to load config file and
   load the `plist` on this repo.
2. In the profiles, load the profile in this repo and set as default.

## Fish and Fisher

Install [Fisher](https://github.com/jorgebucaran/fisher)
Run `fisher update`

## Neovim & tmux

First install pynvim:

```shell
python2 -m pip install --user --upgrade pynvim
python3 -m pip install --user --upgrade pynvim
```

Then:

1. Install [codicon](https://github.com/microsoft/vscode-codicons/blob/main/dist/codicon.ttf) font
2. Clone [.tmux](https://github.com/gpakosz/.tmux) into ~ directory.
3. Install NeoVim.
4. Open NeoVim (lazy.nvim should auto install itself and the plugins)
    1. Run `:checkhealth mason` for the list of dependencies from mason to install lsp servers and tools

## Dev

Install sdkman, rustup and run `nvm install node`

### Cargo

* bindgen-cli
* cargo-bundle
* cargo-deny
* cargo-edit
* cargo-expand
* cargo-generate
* cargo-license
* cargo-make
* cargo-nextest
* cargo-tree
* cargo-update
* cargo-watch
* diffr
* flamegraph
* git-cliff
* miri
* rust-code-analysis-cli
* rust-script
* rusty-man (--locked)
* silicon
* stylua
* wasm-pack
* websocat

### Npm

* typescript
* typings
* vsce
* yarn
* eslint
* eslint_d
* tslint
* write-good
* fixjson

## Safari Extensions

1. 1Blocker
2. Duplicate!
3. Instapaper
4. 1Password
5. JSON Peep
6. Polyglot

## Other Apps

1. Meeter
2. GameTrack
3. [EurKey](https://eurkey.steffen.bruentjen.eu)
4. MarkText (cask) or Marxico
5. Dash
6. ngrok (cask)

## To Remember

1. If ssh doesn't work with the yubikey connected, run `gpg --card-status` and `ssh-add -L`. Both must work otherwise something is wrong. Check environment vars for the `SSH_AUTH_SOCK`.
2. `ykman oath accounts code -s "SEARCH_QUERY"` returns the 2FA from the service queried in the yubikey.
3. Create a file in the home with the name `.fish_variables` and call in it `set -xU VAR_NAME VAR_VAULE` to set secret values in fish env.
4. Copy the file `DefaultKeyBinding.dict` to `~/Library/KeyBindings/`
