#!/usr/bin/env fish
# Update all system components: flake inputs, extensions

set -l RED '\033[0;31m'
set -l GREEN '\033[0;32m'
set -l BLUE '\033[0;34m'
set -l YELLOW '\033[0;33m'
set -l NC '\033[0m'

function run
    $argv
    or begin
        echo -e $RED"Command failed: $argv"$NC
        exit 1
    end
end

set -l rebuild false
set -l show_help false

for arg in $argv
    switch $arg
        case -r --rebuild
            set rebuild true
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
    echo "  - Nix flake inputs (including neovim plugins)"
    echo "  - Firefox extensions"
    echo "  - Thunderbird extensions"
    echo ""
    echo "Options:"
    echo "  -r, --rebuild    Rebuild NixOS configuration after updating"
    echo "  -h, --help       Show this help message"
    exit 0
end

echo -e $BLUE"══════════════════════════════════════════"$NC
echo -e $BLUE"       System Update"$NC
echo -e $BLUE"══════════════════════════════════════════"$NC
echo ""

echo -e $YELLOW"[1/3] Updating flake inputs..."$NC
run nix flake update --flake ~/nixos
echo ""

echo -e $YELLOW"[2/3] Updating Firefox extensions..."$NC
run update-firefox
echo ""

echo -e $YELLOW"[3/3] Updating Thunderbird extensions..."$NC
run update-thunderbird
echo ""

echo -e $GREEN"══════════════════════════════════════════"$NC
echo -e $GREEN"       All updates complete!"$NC
echo -e $GREEN"══════════════════════════════════════════"$NC

if test $rebuild = true
    echo ""
    echo -e $YELLOW"Rebuilding NixOS configuration..."$NC
    run sudo nixos-rebuild switch --flake ~/nixos#laptop
    echo ""
    echo -e $GREEN"System rebuild complete!"$NC
else
    echo ""
    echo "To apply changes, run:"
    echo "  sudo nixos-rebuild switch --flake ~/nixos#laptop"
    echo "  update-system --rebuild"
end
