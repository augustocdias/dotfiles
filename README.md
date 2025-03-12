# Personal Settings and Tools

My personal mac os settings and tools

First of all install command line tools and rosetta (the install script should be doing all of it).

## Brew Tips

To generate the dump: `brew bundle dump`

To install from the bundle: `brew bundle install`

## Install

Run the script `./install_deps.sh`

### Cargo

- bindgen-cli
- cargo-bundle
- cargo-deny
- cargo-edit
- cargo-expand
- cargo-generate
- cargo-license
- cargo-make
- cargo-nextest
- cargo-tree
- cargo-update
- cargo-watch
- diffr
- flamegraph
- git-cliff
- miri
- rust-code-analysis-cli
- rust-script
- rusty-man (--locked)
- silicon
- stylua
- wasm-pack
- websocat

### Npm

- yarn
- fixjson

## Safari Extensions

1. 1Blocker
2. Duplicate!
3. 1Password
4. JSON Peep
5. Polyglot

## Other Apps

1. Meeter
2. GameTrack
3. [EurKey](https://eurkey.steffen.bruentjen.eu)
4. Dash
5. ngrok (cask)

## To Remember

1. If ssh doesn't work with the yubikey connected, run `gpg --card-status` and `ssh-add -L`. Both must work otherwise something is wrong. Check environment vars for the `SSH_AUTH_SOCK`.
2. `ykman oath accounts code -s "SEARCH_QUERY"` returns the 2FA from the service queried in the yubikey.
3. Create a file in the home with the name `.fish_secret_variables.fish` and call in it `set -gx VAR_NAME VAR_VAULE` to set secret values in fish env.
