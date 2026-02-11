#!/usr/bin/env fish
# Update all system components: flake inputs, extensions, plugins

# Colors
set -l RED '\033[0;31m'
set -l GREEN '\033[0;32m'
set -l BLUE '\033[0;34m'
set -l YELLOW '\033[0;33m'
set -l NC '\033[0m'

# Parse arguments
set -l rebuild false
set -l home_only false
set -l show_help false

for arg in $argv
    switch $arg
        case -r --rebuild
            set rebuild true
        case --home
            set home_only true
        case -h --help
            set show_help true
        case '*'
            echo -e $RED"Unknown option: $arg"$NC
            set show_help true
    end
end

if test $show_help = true
    echo "Usage: update-system [options]"
    echo ""
    echo "Update all system components:"
    echo "  - Nix flake inputs"
    echo "  - Neovim plugins"
    echo "  - Firefox extensions"
    echo "  - Thunderbird extensions"
    echo "  - Vicinae extensions"
    echo ""
    echo "Options:"
    echo "  -r, --rebuild    Rebuild NixOS configuration after updating"
    echo "  --home           Rebuild home-manager only (no sudo required)"
    echo "  -h, --help       Show this help message"
    exit 0
end

echo -e $BLUE"══════════════════════════════════════════"$NC
echo -e $BLUE"       System Update"$NC
echo -e $BLUE"══════════════════════════════════════════"$NC
echo ""

# Update flake inputs
echo -e $YELLOW"[1/5] Updating flake inputs..."$NC
nix flake update --flake ~/nixos
echo ""

# Update Neovim plugins
echo -e $YELLOW"[2/5] Updating Neovim plugins..."$NC
update-nvim --update-tags
echo ""

# Update Firefox extensions
echo -e $YELLOW"[3/5] Updating Firefox extensions..."$NC
update-firefox
echo ""

# Update Thunderbird extensions
echo -e $YELLOW"[4/5] Updating Thunderbird extensions..."$NC
update-thunderbird
echo ""

# Update Vicinae extensions
echo -e $YELLOW"[5/5] Updating Vicinae extensions..."$NC
update-vicinae
echo ""

echo -e $GREEN"══════════════════════════════════════════"$NC
echo -e $GREEN"       All updates complete!"$NC
echo -e $GREEN"══════════════════════════════════════════"$NC

if test $home_only = true
    echo ""
    echo -e $YELLOW"Rebuilding home-manager configuration..."$NC
    nix run home-manager -- switch --flake ~/nixos#augusto

    if test $status -eq 0
        echo ""
        echo -e $GREEN"Home-manager rebuild complete!"$NC
    else
        echo ""
        echo -e $RED"Home-manager rebuild failed!"$NC
        exit 1
    end
else if test $rebuild = true
    echo ""
    echo -e $YELLOW"Rebuilding NixOS configuration..."$NC
    sudo nixos-rebuild switch --flake ~/nixos#augusto

    if test $status -eq 0
        echo ""
        echo -e $GREEN"System rebuild complete!"$NC
    else
        echo ""
        echo -e $RED"System rebuild failed!"$NC
        exit 1
    end
else
    echo ""
    echo "To apply changes, run:"
    echo "  sudo nixos-rebuild switch --flake ~/nixos#augusto"
    echo "  update-system --rebuild  (full system)"
    echo "  update-system --home     (home-manager only)"
end
