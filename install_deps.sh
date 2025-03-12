#!/usr/bin/env bash

# Install Rosetta and Command Line Tools
xcode-select --install
sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license

# Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle install --file .others/Brewfile

# Neovim
brew rm nvim --ignore-dependencies
bob install latest
bob install nightly
bob use nightly

# Create symlinks for dot files
stow */

# Set fish as default shell
echo "/opt/homebrew/bin/fish" | sudo tee -a /etc/shells
chsh -s $(which fish)

fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"

# restart gpg to reload configs
gpg-connect-agent reloadagent /bye

# Add completions for tools
fish -c "delta --generate-completion fish > $__fish_config_dir/completions/delta.fish"
fish -c "zellij setup --generate-completion fish > $__fish_config_dir/completions/zellij.fish"
fish -c "bob complete fish > $__fish_config_dir/completions/bob.fish"

# Make Home and End keys work as expected in MacOS
cp ./.others/DefaultKeyBinding.dict ~/Library/KeyBindings/

# Create dir for enhancd to cache
mkdir ~/.enhancd
