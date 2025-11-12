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
while true; do
    read -s -p "Enter password for $USERNAME: " PASSWORD
    echo ""
    read -s -p "Confirm password: " PASSWORD2
    echo ""

    if [ "$PASSWORD" = "$PASSWORD2" ]; then
        if [ ${#PASSWORD} -ge 8 ]; then
            break
        else
            echo -e "${RED}Password must be at least 8 characters.${NC}"
        fi
    else
        echo -e "${RED}Passwords do not match. Try again.${NC}"
    fi
done

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
mkdir -p /opt/home/nixos/modules
mkdir -p /opt/home/.config
mkdir -p /opt/home/.local

# Copy flake.nix to root of nixos directory
cp /etc/nixos-installer/flake.nix /opt/home/nixos/

# Copy module files to modules/ subdirectory
cp /etc/nixos-installer/configuration.nix /opt/home/nixos/modules/
cp /etc/nixos-installer/hyprland-config.nix /opt/home/nixos/modules/
cp /etc/nixos-installer/packages.nix /opt/home/nixos/modules/
cp /etc/nixos-installer/eurkey.nix /opt/home/nixos/modules/
cp /etc/nixos-installer/grub-config.nix /opt/home/nixos/modules/

# Move hardware-configuration.nix to root of nixos directory
cp /mnt/etc/nixos/hardware-configuration.nix /opt/home/nixos/

# Update configuration.nix with actual username
sed -i "s/USERNAME_PLACEHOLDER/$USERNAME/g" /opt/home/nixos/modules/configuration.nix

# Set ownership of temp nixos directory (user will be created by homectl later)
mkdir -p /opt/home
chown -R 1000:100 /opt/home/nixos

# ===== INSTALL NIXOS =====
echo ""
echo -e "${YELLOW}Installing NixOS... (10-20 minutes)${NC}"

# Use the target disk for temporary nix store to avoid filling RAM
mkdir -p /mnt/nix-install-tmp
export TMPDIR=/mnt/nix-install-tmp

cd /opt/home/nixos && nix flake update

# Install using flake from temp directory
nixos-install --flake /opt/home/nixos#augusto --no-root-password

# Clean up
rm -rf /mnt/nix-install-tmp

# Remove /etc/nixos - all config will be moved to ~/.dotfiles/nixos/nixos
rm -rf /mnt/etc/nixos
echo -e "${GREEN}✓ NixOS installed${NC}"

# ===== SETUP SYSTEMD-HOMED USER CREATION ON FIRST BOOT =====
echo ""
echo -e "${YELLOW}Setting up user creation for first boot...${NC}"

mkdir /mnt/opt

# Create first-boot setup script
cat >/mnt/tmp/first-boot-setup.fish <<EOF
#!/run/current-system/sw/bin/fish

set USERNAME $argv[1]

homectl create $USERNAME --real-name="$USERNAME" --member-of=wheel --shell=/run/current-system/sw/bin/fish --storage=luks

# Get user's home directory
set USER_HOME (homectl inspect "$USERNAME" -j | grep -Po '"homeDirectory":\s*"\K[^"]+')

homectl with $USERNAME -- rsync -arHAXv --remove-source-files /opt/home/ .

# Copy dotfiles to user home
cp -r /opt/first-boot-setup/dotfiles "$USER_HOME/.dotfiles"

# Run stow to create symlinks
cd "$USER_HOME/.dotfiles"
env HOME="$USER_HOME" stow .

# Set ownership
set USER_ID (id -u "$USERNAME")
set USER_GID (id -g "$USERNAME")
chown -R "$USER_ID:$USER_GID" "$USER_HOME/.dotfiles"
chown -R "$USER_ID:$USER_GID" "$USER_HOME/.config"; or true
chown -R "$USER_ID:$USER_GID" "$USER_HOME/.local"; or true

# Clean up
rm -f /etc/systemd/system/create-homed-user.service
systemctl daemon-reload

rm -rf /opt/first-boot-setup
rm -f /opt/first-boot-setup.fish
EOF

chmod +x /mnt/tmp/first-boot-setup.fish

# Create service file in /mnt/tmp (accessible as /tmp inside nixos-enter)
cat >/mnt/tmp/create-homed-user.service <<EOF
[Unit]
Description=Create systemd-homed user on first boot
After=systemd-homed.service
Before=display-manager.service
ConditionPathExists=/opt/first-boot-setup.fish

[Service]
Type=oneshot
Environment="NEWPASSWORD=${PASSWORD}"
ExecStart=/opt/first-boot-setup.fish ${USERNAME}
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Move files and enable service using nixos-enter
nixos-enter --root /mnt -- mv /tmp/first-boot-setup.fish /opt/first-boot-setup.fish
nixos-enter --root /mnt -- mv /tmp/create-homed-user.service /etc/systemd/system/create-homed-user.service
nixos-enter --root /mnt -- systemctl enable create-homed-user.service

echo -e "${GREEN}✓ User will be created automatically on first boot${NC}"
echo -e "${YELLOW}⚠ Important: You will need to login at the console after first boot${NC}"
echo -e "${YELLOW}  The user will be created with the password you entered.${NC}"

# ===== SETUP DOTFILES =====
echo ""
echo -e "${YELLOW}Setting up dotfiles...${NC}"

# Clone dotfiles to temporary location
mkdir -p /mnt/opt/first-boot-setup
git clone https://github.com/augustocdias/dotfiles.git /mnt/opt/first-boot-setup/dotfiles
echo -e "${GREEN}✓ Dotfiles cloned${NC}"

# Move nixos config into temp dotfiles structure
mkdir -p /mnt/opt/first-boot-setup/dotfiles/nixos
mv /opt/home/nixos /mnt/opt/first-boot-setup/dotfiles/nixos/nixos
echo -e "${GREEN}✓ NixOS config moved to dotfiles${NC}"

# Install fisher (run as root with HOME set to dotfiles location)
echo -e "${YELLOW}Installing fisher for fish shell...${NC}"
if nixos-enter --root /mnt -- env HOME=/opt/first-boot-setup/dotfiles/fish fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"; then
    echo -e "${GREEN}✓ Fisher installed${NC}"
else
    echo -e "${YELLOW}⚠ Fisher installation had issues (may complete on first boot)${NC}"
fi

# Install neovim plugins (run as root with HOME set to dotfiles location)
echo -e "${YELLOW}Installing Neovim plugins...${NC}"
if nixos-enter --root /mnt -- env XDG_CONFIG_HOME=/opt/first-boot-setup/dotfiles/neovim/.config HOME=/opt/home/ nvim --headless "+Lazy! sync" +qa; then
    echo -e "${GREEN}✓ Neovim Lazy plugins installed${NC}"
else
    echo -e "${YELLOW}⚠ Neovim plugin installation had issues (may complete on first boot)${NC}"
fi

if nixos-enter --root /mnt -- env XDG_CONFIG_HOME=/opt/first-boot-setup/dotfiles/neovim/.config HOME=/opt/home/nvim --headless "+TSUpdateSync" +qa; then
    echo -e "${GREEN}✓ Neovim treesitter parsers installed${NC}"
else
    echo -e "${YELLOW}⚠ Treesitter installation had issues (may complete on first boot)${NC}"
fi

echo -e "${GREEN}✓ Dotfiles setup complete${NC}"

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
echo "  • Username: $USERNAME (will be created on first boot)"
echo "  • Password: as you entered during installation"
echo "  • Shell: fish"
echo "  • Home: encrypted with systemd-homed"
echo "  • Dotfiles: cloned and stowed"
echo "  • NixOS config: ~/.dotfiles/nixos/nixos"
echo "  • Neovim: plugins and parsers installed"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  • Your user will be created automatically on first boot"
echo "  • Wait for the boot process to complete before logging in"
echo "  • Then login with your username and password"
echo "  • Your home directory will be automatically decrypted"
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
