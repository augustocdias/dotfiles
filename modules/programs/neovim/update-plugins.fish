#!/usr/bin/env fish
# Update all nvim-* flake inputs (neovim plugins)

set -l RED '\033[0;31m'
set -l GREEN '\033[0;32m'
set -l YELLOW '\033[0;33m'
set -l NC '\033[0m'

set -l flake_dir (test (count $argv) -gt 0; and echo $argv[1]; or echo "$HOME/nixos")

set -l plugins (nix flake metadata "$flake_dir" --json \
    | jq -r '.locks.nodes | keys[] | select(startswith("nvim-"))'); or begin
    echo -e $RED"Failed to read flake metadata from $flake_dir"$NC
    exit 1
end

if test -z "$plugins"
    echo -e $RED"No nvim-* inputs found in flake.lock"$NC
    exit 1
end

echo -e $YELLOW"Updating neovim plugins:"$NC
for p in $plugins
    echo "  $p"
end
echo ""

nix flake update $plugins --flake "$flake_dir"; or begin
    echo -e $RED"Failed to update neovim plugins"$NC
    exit 1
end

echo -e $GREEN"Neovim plugins updated."$NC
