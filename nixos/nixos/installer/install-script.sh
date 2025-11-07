#!/usr/bin/env bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "$BLUE"
echo "╔════════════════════════════════════════════╗"
echo "║   NixOS Interactive Installer              ║"
echo "╚════════════════════════════════════════════╝"
echo -e "$NC"
echo ""

# ===== CHECK INTERNET CONNECTION =====
echo -e "$YELLOW"
echo "Checking internet connection..."
echo -e "$NC"

if ping -c 1 8.8.8.8 &>/dev/null; then
    echo -e "$GREEN"
    echo "✓ Internet connected via ethernet"
    echo -e "$NC"
else
    echo -e "$YELLOW"
    echo "No internet connection detected."
    echo "Setting up WiFi..."
    echo -e "$NC"

    # Show available networks
    nmcli device wifi list
    echo ""

    read -p "Enter WiFi SSID: " WIFI_SSID
    read -s -p "Enter WiFi password: " WIFI_PASSWORD
    echo ""

    echo -e "$YELLOW"
    echo "Connecting to WiFi..."
    echo -e "$NC"
    nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASSWORD"

    sleep 3

    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo -e "$GREEN"
        echo "✓ WiFi connected successfully"
        echo -e "$NC"
    else
        echo -e "$RED"
        echo "✗ Failed to connect to WiFi. Please check credentials."
        echo -e "$NC"
        exit 1
    fi
fi

echo ""

# ===== USERNAME =====
while true; do
    read -p "Enter username: " USERNAME
    if [[ -n "$USERNAME" && "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        break
    fi
    echo -e "$RED"
    echo "Invalid username. Must start with lowercase letter or underscore."
    echo -e "$NC"
done

# ===== PASSWORD =====
# HARDCODED FOR TESTING - CHANGE IN PRODUCTION!
PASSWORD="12345678"
echo "Using test password: 12345678"

# while true; do
#   read -s -p "Enter password for $USERNAME: " PASSWORD
#   echo ""
#   read -s -p "Confirm password: " PASSWORD2
#   echo ""
#
#   if [ "$PASSWORD" = "$PASSWORD2" ]; then
#     if [ ${#PASSWORD} -ge 8 ]; then
#       break
#     else
#       echo -e "${RED}Password must be at least 8 characters.${NC}"
#     fi
#   else
#     echo -e "${RED}Passwords do not match. Try again.${NC}"
#   fi
# done

# ===== DISK PARTITIONING =====
echo ""
echo -e "${YELLOW}Starting interactive disk partitioning...${NC}"
echo ""

# Call the partition-disk.sh script
if [ -f /etc/nixos-installer/partition-disk.sh ]; then
    bash /etc/nixos-installer/partition-disk.sh
else
    echo -e "${RED}✗ partition-disk.sh not found!${NC}"
    exit 1
fi

# Source the partition info
if [ -f /tmp/partition-info ]; then
    source /tmp/partition-info
    echo -e "${GREEN}✓ Disk partitioning complete${NC}"
else
    echo -e "${RED}✗ Partition info not found!${NC}"
    exit 1
fi

# ===== SUMMARY =====
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Installation Summary              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "  Username:    $USERNAME"
echo "  Disk:        $DISK"
echo "  Root:        $ROOT_PART ($ROOT_FS)"
if [ -n "$HOME_PART" ]; then
    echo "  Home:        $HOME_PART ($HOME_FS)"
fi
if [ -n "$SWAP_PART" ]; then
    echo "  Swap:        $SWAP_PART"
elif [ "$SWAP_TYPE" = "swapfile" ]; then
    echo "  Swap:        ${SWAP_SIZE}GB swapfile"
fi
echo "  Encryption:  systemd-homed (encrypted home directory)"
echo "  Dotfiles:    github.com/augustocdias/dotfiles"
echo ""

while true; do
    read -p "Continue with installation? (yes/no): " CONFIRM
    case $CONFIRM in
    yes) break ;;
    no)
        echo "Installation cancelled."
        exit 0
        ;;
    *) echo -e "${RED}Please type 'yes' or 'no'$NC" ;;
    esac
done

# ===== GENERATE HARDWARE CONFIG =====
echo -e "$YELLOW"
echo "Generating hardware configuration..."
echo -e "$NC"
nixos-generate-config --root /mnt

# ===== CREATE CONFIGURATION =====
echo -e "$YELLOW"
echo "Creating system configuration..."
echo -e "$NC"

# Create temporary nixos config directory for installation
mkdir -p /mnt/home/$USERNAME/nixos/modules

# Copy flake.nix to root of nixos directory
cp /etc/nixos-installer/flake.nix /mnt/home/$USERNAME/nixos/

# Copy module files to modules/ subdirectory
cp /etc/nixos-installer/configuration.nix /mnt/home/$USERNAME/nixos/modules/
cp /etc/nixos-installer/hyprland-config.nix /mnt/home/$USERNAME/nixos/modules/
cp /etc/nixos-installer/packages.nix /mnt/home/$USERNAME/nixos/modules/
cp /etc/nixos-installer/eurkey.nix /mnt/home/$USERNAME/nixos/modules/
cp /etc/nixos-installer/refind-config.nix /mnt/home/$USERNAME/nixos/modules/

# Copy refind theme directory
cp -r /etc/nixos-installer/refind-theme /mnt/home/$USERNAME/nixos/modules/

# Move hardware-configuration.nix to root of nixos directory
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/$USERNAME/nixos/

# Update configuration.nix with actual username
sed -i "s/USERNAME_PLACEHOLDER/$USERNAME/g" /mnt/home/$USERNAME/nixos/modules/configuration.nix

# Set ownership of temp nixos directory (user will be created by homectl later)
mkdir -p /mnt/home/$USERNAME
chown -R 1000:100 /mnt/home/$USERNAME/nixos

# ===== INSTALL NIXOS =====
echo ""
echo -e "${YELLOW}Installing NixOS... (10-20 minutes)${NC}"

# Use the target disk for temporary nix store to avoid filling RAM
mkdir -p /mnt/nix-install-tmp
export TMPDIR=/mnt/nix-install-tmp

# Install using flake from temp directory
nixos-install --flake /mnt/home/$USERNAME/nixos#augusto --no-root-password

# Clean up
rm -rf /mnt/nix-install-tmp

# Remove /etc/nixos - all config will be moved to ~/.dotfiles/nixos/nixos
rm -rf /mnt/etc/nixos
echo -e "${GREEN}✓ NixOS installed${NC}"

# ===== CREATE SYSTEMD-HOMED USER =====
echo ""
echo -e "${YELLOW}Creating encrypted user with systemd-homed...${NC}"

# Create user with homectl (encrypted home directory)
if nixos-enter --root /mnt -- homectl create "$USERNAME" \
    --real-name="$USERNAME" \
    --member-of=wheel \
    --shell=/run/current-system/sw/bin/fish \
    --storage=luks \
    --password="$PASSWORD"; then
    echo -e "${GREEN}✓ User created with encrypted home directory${NC}"
else
    echo -e "${RED}✗ Failed to create user${NC}"
    exit 1
fi

# Activate the user
if nixos-enter --root /mnt -- homectl activate "$USERNAME"; then
    echo -e "${GREEN}✓ User activated${NC}"
else
    echo -e "${RED}✗ Failed to activate user${NC}"
    exit 1
fi

# ===== SETUP HYPRLAND CONFIG =====
echo ""
echo -e "${YELLOW}Creating Hyprland configuration...${NC}"

# Note: Hyprland config will be managed by dotfiles, no need to create it here

# ===== SETUP DOTFILES =====
echo ""
echo -e "${YELLOW}Setting up dotfiles...${NC}"

# Get the actual home directory path (systemd-homed might use different location)
USER_HOME=$(nixos-enter --root /mnt -- homectl inspect "$USERNAME" -j | grep -Po '"homeDirectory":\s*"\K[^"]+')

# Clone dotfiles repository
echo "Cloning dotfiles to ~/.dotfiles..."
if nixos-enter --root /mnt -- su - "$USERNAME" -c "git clone https://github.com/augustocdias/dotfiles.git $USER_HOME/.dotfiles"; then
    echo -e "${GREEN}✓ Dotfiles cloned${NC}"
else
    echo -e "${RED}✗ Failed to clone dotfiles${NC}"
    exit 1
fi

# Move nixos config into .dotfiles structure
echo "Moving NixOS config into .dotfiles/nixos/nixos..."
nixos-enter --root /mnt -- su - "$USERNAME" -c "mkdir -p $USER_HOME/.dotfiles/nixos"
mv /mnt/home/$USERNAME/nixos "$USER_HOME/.dotfiles/nixos/nixos" 2>/dev/null ||
    nixos-enter --root /mnt -- su - "$USERNAME" -c "mv /home/$USERNAME/nixos $USER_HOME/.dotfiles/nixos/nixos"
echo -e "${GREEN}✓ NixOS config moved to ~/.dotfiles/nixos/nixos${NC}"

# Run stow to symlink dotfiles
echo "Running stow to symlink dotfiles..."
if nixos-enter --root /mnt -- su - "$USERNAME" -c "cd $USER_HOME/.dotfiles && stow ."; then
    echo -e "${GREEN}✓ Dotfiles stowed${NC}"
else
    echo -e "${RED}✗ Failed to stow dotfiles${NC}"
    exit 1
fi

# Install fisher for fish shell
echo -e "${YELLOW}Installing fisher for fish shell...${NC}"
if nixos-enter --root /mnt -- su - "$USERNAME" -c 'fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"'; then
    echo -e "${GREEN}✓ Fisher installed${NC}"
else
    echo -e "${RED}✗ Failed to install fisher${NC}"
    exit 1
fi

# ===== NEOVIM SETUP =====
echo ""
echo -e "${YELLOW}Setting up Neovim plugins and parsers...${NC}"

# Install Lazy plugins
echo "Installing Lazy plugins..."
if nixos-enter --root /mnt -- su - "$USERNAME" -c 'nvim --headless "+Lazy! sync" +qa'; then
    echo -e "${GREEN}✓ Lazy plugins installed${NC}"
else
    echo -e "${YELLOW}⚠ Lazy plugin installation had issues (this is sometimes normal on first run)${NC}"
fi

# Install treesitter parsers
echo "Installing treesitter parsers..."
if nixos-enter --root /mnt -- su - "$USERNAME" -c 'nvim --headless "+TSUpdateSync" +qa'; then
    echo -e "${GREEN}✓ Treesitter parsers installed${NC}"
else
    echo -e "${YELLOW}⚠ Treesitter parser installation had issues (this is sometimes normal on first run)${NC}"
fi

echo -e "${GREEN}✓ Neovim setup complete${NC}"

# ===== COMPLETION =====
rm -f /tmp/partition-info

clear
echo -e "$GREEN"
echo "╔════════════════════════════════════════════╗"
echo "║     Installation Complete!                 ║"
echo "╚════════════════════════════════════════════╝"
echo -e "$NC"
echo ""
echo "Your system is ready!"
echo "  • Username: $USERNAME"
echo "  • Shell: fish"
echo "  • Home: encrypted with systemd-homed"
echo "  • Dotfiles: cloned and stowed"
echo "  • NixOS config: ~/.dotfiles/nixos/nixos"
echo "  • Neovim: plugins and parsers installed"
echo ""
echo "On reboot, login with your username and password"
echo "(Your home directory will be automatically decrypted)"
echo ""
echo "To rebuild your system after making changes:"
echo "  cd ~/.dotfiles/nixos/nixos && sudo nixos-rebuild switch --flake .#augusto"
echo ""

# Prompt for reboot or shell
while true; do
    echo -e "${YELLOW}What would you like to do?${NC}"
    echo "  [R] Reboot now"
    echo "  [S] Drop to shell"
    echo ""
    read -p "Choice (R/S): " choice

    case "${choice^^}" in
    R)
        echo ""
        echo "Rebooting..."
        sleep 2
        reboot
        ;;
    S)
        echo ""
        echo -e "${GREEN}Dropped to shell. Type 'exit' to return to installer menu.${NC}"
        echo ""
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice. Please enter R or S.${NC}"
        echo ""
        ;;
    esac
done
