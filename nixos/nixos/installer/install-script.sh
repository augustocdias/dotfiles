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
# Hardcoded username
USERNAME="augusto"

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

# Call the partition-disk.sh script with password
if [ -f /etc/nixos-installer/partition-disk.sh ]; then
    bash /etc/nixos-installer/partition-disk.sh "$PASSWORD"
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
echo "  Encryption:  LUKS2 (full disk encryption with TPM2/FIDO2)"
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

# ===== SETUP DOTFILES =====
echo ""
echo -e "${YELLOW}Setting up dotfiles and configuration...${NC}"

# Clone dotfiles first
git clone https://github.com/augustocdias/dotfiles.git /mnt/home/augusto/.dotfiles
echo -e "${GREEN}✓ Dotfiles cloned${NC}"

# Create nixos config directory structure
mkdir -p /mnt/home/augusto/.dotfiles/nixos/nixos/modules

# Copy nixos configs from ISO to dotfiles
cp /etc/nixos-installer/flake.nix /mnt/home/augusto/.dotfiles/nixos/nixos/
cp /etc/nixos-installer/configuration.nix /mnt/home/augusto/.dotfiles/nixos/nixos/modules/
cp /etc/nixos-installer/hyprland-config.nix /mnt/home/augusto/.dotfiles/nixos/nixos/modules/
cp /etc/nixos-installer/packages.nix /mnt/home/augusto/.dotfiles/nixos/nixos/modules/
cp /etc/nixos-installer/eurkey.nix /mnt/home/augusto/.dotfiles/nixos/nixos/modules/
cp /etc/nixos-installer/grub-config.nix /mnt/home/augusto/.dotfiles/nixos/nixos/modules/
echo -e "${GREEN}✓ NixOS configs copied${NC}"

# Generate hardware-configuration.nix directly into dotfiles
nixos-generate-config --root /mnt --dir /mnt/home/augusto/.dotfiles/nixos/nixos
echo -e "${GREEN}✓ Hardware configuration generated${NC}"

# Create secrets directory and store hashed password
mkdir -p /mnt/etc/nixos/secrets
chmod 700 /mnt/etc/nixos/secrets
printf "%s" "$PASSWORD" | mkpasswd -m yescrypt -s > /mnt/etc/nixos/secrets/augusto-password
chmod 600 /mnt/etc/nixos/secrets/augusto-password
echo -e "${GREEN}✓ Password hash stored securely${NC}"

# ===== INSTALL NIXOS =====
echo ""
echo -e "${YELLOW}Installing NixOS... (10-20 minutes)${NC}"

# Use the target disk for temporary nix store to avoid filling RAM
mkdir -p /mnt/nix-install-tmp
export TMPDIR=/mnt/nix-install-tmp

cd /mnt/home/augusto/.dotfiles/nixos/nixos && nix flake update

# Install using flake from dotfiles
nixos-install --flake /mnt/home/augusto/.dotfiles/nixos/nixos#augusto --no-root-password

# Clean up
rm -rf /mnt/nix-install-tmp
echo -e "${GREEN}✓ NixOS installed${NC}"

# ===== TPM2 & FIDO2 ENROLLMENT =====
echo ""
echo -e "${YELLOW}Enrolling TPM2 and FIDO2 for disk auto-unlock...${NC}"

# Read LUKS encrypted partitions
if [ -f /tmp/luks-devices ]; then
  while IFS=: read -r mount_point partition; do
    echo ""
    echo -e "${CYAN}Enrolling keys for $partition ($mount_point)${NC}"

    # Try TPM2 enrollment
    if printf "%s" "$PASSWORD" | nixos-enter --root /mnt -- \
      systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 "$partition" -; then
      echo -e "${GREEN}✓ TPM2 enrolled for $partition${NC}"

      # Set TPM2 slot as preferred (slot 1)
      nixos-enter --root /mnt -- cryptsetup config "$partition" --priority prefer --key-slot 1 || true
    else
      echo -e "${YELLOW}⚠ TPM2 enrollment failed (may not be available in VM)${NC}"
    fi

    # Enroll FIDO2
    echo -e "${YELLOW}Please insert your FIDO2 key for $partition and press Enter...${NC}"
    read
    if printf "%s" "$PASSWORD" | nixos-enter --root /mnt -- \
      systemd-cryptenroll --fido2-device=auto "$partition" -; then
      echo -e "${GREEN}✓ FIDO2 enrolled for $partition${NC}"
    else
      echo -e "${YELLOW}⚠ FIDO2 enrollment failed${NC}"
    fi
  done < /tmp/luks-devices
else
  echo -e "${YELLOW}⚠ No LUKS devices found for enrollment${NC}"
fi

echo -e "${GREEN}✓ Enrollment complete${NC}"

# ===== SETUP USER ENVIRONMENT =====
echo ""
echo -e "${YELLOW}Setting up user environment...${NC}"

# Stow dotfiles
cd /mnt/home/augusto/.dotfiles
nixos-enter --root /mnt -- env HOME=/home/augusto stow -d /home/augusto/.dotfiles -t /home/augusto .
echo -e "${GREEN}✓ Dotfiles stowed${NC}"

# Install fisher
echo -e "${YELLOW}Installing fisher...${NC}"
if nixos-enter --root /mnt -- env HOME=/home/augusto fish -c \
  "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"; then
  echo -e "${GREEN}✓ Fisher installed${NC}"
else
  echo -e "${YELLOW}⚠ Fisher installation had issues${NC}"
fi

# Install neovim plugins
echo -e "${YELLOW}Installing Neovim plugins...${NC}"
if nixos-enter --root /mnt -- env HOME=/home/augusto nvim --headless "+Lazy! sync" +qa; then
  echo -e "${GREEN}✓ Neovim Lazy plugins installed${NC}"
else
  echo -e "${YELLOW}⚠ Neovim plugin installation had issues${NC}"
fi

if nixos-enter --root /mnt -- env HOME=/home/augusto nvim --headless "+TSUpdateSync" +qa; then
  echo -e "${GREEN}✓ Neovim treesitter parsers installed${NC}"
else
  echo -e "${YELLOW}⚠ Treesitter installation had issues${NC}"
fi

# Set ownership
nixos-enter --root /mnt -- chown -R augusto:users /home/augusto
echo -e "${GREEN}✓ Ownership set${NC}"

echo -e "${GREEN}✓ User environment complete${NC}"

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
echo "  • Password: as you entered"
echo "  • Shell: fish"
echo "  • Encryption: LUKS2 with TPM2/FIDO2 auto-unlock"
echo "  • Dotfiles: ~/.dotfiles (stowed)"
echo "  • NixOS config: ~/.dotfiles/nixos/nixos"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "  • Disk will auto-unlock via TPM2 (if available)"
echo "  • Fallback to FIDO2 key if TPM2 fails"
echo "  • Password fallback if FIDO2 unavailable"
echo "  • Login with username: $USERNAME"
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
