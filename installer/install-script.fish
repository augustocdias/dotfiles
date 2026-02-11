#!/usr/bin/env fish

# Colors
set RED '\033[0;31m'
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set BLUE '\033[0;34m'
set CYAN '\033[0;36m'
set NC '\033[0m'

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

if ping -c 1 8.8.8.8 &>/dev/null
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

    read -P "Enter WiFi SSID: " WIFI_SSID
    read -sP "Enter WiFi password: " WIFI_PASSWORD
    echo ""

    echo -e "$YELLOW"
    echo "Connecting to WiFi..."
    echo -e "$NC"
    nmcli device wifi connect "$WIFI_SSID" password "$WIFI_PASSWORD"

    sleep 3

    if ping -c 1 8.8.8.8 &>/dev/null
        echo -e "$GREEN"
        echo "✓ WiFi connected successfully"
        echo -e "$NC"
    else
        echo -e "$RED"
        echo "✗ Failed to connect to WiFi. Please check credentials."
        echo -e "$NC"
        exit 1
    end
end

echo ""

# ===== USERNAME =====
set USERNAME augusto

# ===== PASSWORD =====
while true
    read -sP "Enter password for $USERNAME: " PASSWORD
    echo ""
    read -sP "Confirm password: " PASSWORD2
    echo ""

    if test "$PASSWORD" = "$PASSWORD2"
        if test (string length "$PASSWORD") -ge 8
            break
        else
            echo -e "$RED""Password must be at least 8 characters.$NC"
        end
    else
        echo -e "$RED""Passwords do not match. Try again.$NC"
    end
end

# ===== DISK PARTITIONING =====
echo ""
echo -e "$YELLOW""Starting interactive disk partitioning...$NC"
echo ""

# Call the partition-disk.fish script with password
if test -f /etc/partition-disk.fish
    fish /etc/partition-disk.fish "$PASSWORD"
else
    echo -e "$RED""✗ partition-disk.fish not found!$NC"
    exit 1
end

# Source the partition info (bash-style file, need to parse it)
if test -f /tmp/partition-info
    for line in (cat /tmp/partition-info)
        set parts (string split "=" $line)
        if test (count $parts) -eq 2
            set -g $parts[1] $parts[2]
        end
    end
    echo -e "$GREEN""✓ Disk partitioning complete$NC"
else
    echo -e "$RED""✗ Partition info not found!$NC"
    exit 1
end

# ===== SUMMARY =====
echo ""
echo -e "$BLUE""╔════════════════════════════════════════════╗$NC"
echo -e "$BLUE""║          Installation Summary              ║$NC"
echo -e "$BLUE""╚════════════════════════════════════════════╝$NC"
echo ""
echo "  Username:    $USERNAME"
echo "  Disk:        $DISK"
echo "  Root:        $ROOT_PART ($ROOT_FS)"
if test -n "$HOME_PART"
    echo "  Home:        $HOME_PART ($HOME_FS)"
end
if test -n "$SWAP_PART"
    echo "  Swap:        $SWAP_PART"
else if test "$SWAP_TYPE" = swapfile
    echo "  Swap:        {$SWAP_SIZE}GB swapfile"
end
echo "  Encryption:  LUKS2 (full disk encryption with TPM2/FIDO2)"
echo "  Dotfiles:    github.com/augustocdias/dotfiles"
echo ""

while true
    read -P "Continue with installation? (yes/no): " CONFIRM
    switch $CONFIRM
        case yes
            break
        case no
            echo "Installation cancelled."
            exit 0
        case '*'
            echo -e "$RED""Please type 'yes' or 'no'$NC"
    end
end

# ===== SETUP DOTFILES =====
echo ""
echo -e "$YELLOW""Setting up dotfiles and configuration...$NC"

# Clone dotfiles
git clone https://github.com/augustocdias/dotfiles.git /mnt/home/augusto/nixos
echo -e "$GREEN""✓ Dotfiles cloned$NC"

# Clone media files
git clone https://github.com/augustocdias/media.git /mnt/home/augusto/media
echo -e "$GREEN""✓ Media files cloned$NC"

# Generate hardware-configuration.nix directly into dotfiles
nixos-generate-config --show-hardware-config --root /mnt >/mnt/home/augusto/nixos/hardware-configuration.nix
echo -e "$GREEN""✓ Hardware configuration generated$NC"

# Create secrets directory and store hashed password
mkdir -p /mnt/etc/nixos/secrets
chmod 700 /mnt/etc/nixos/secrets
printf "%s" "$PASSWORD" | mkpasswd -m yescrypt -s >/mnt/etc/nixos/secrets/augusto-password
chmod 600 /mnt/etc/nixos/secrets/augusto-password
echo -e "$GREEN""✓ Password hash stored securely$NC"

# ===== INSTALL NIXOS =====
echo ""
echo -e "$YELLOW""Installing NixOS... Be patient and please wait...$NC"

nixos-install --flake path:/mnt/home/augusto/nixos#augusto --no-root-password

echo -e "$GREEN""✓ NixOS installed$NC"

# ===== TPM2 & FIDO2 ENROLLMENT =====
echo ""
echo -e "$YELLOW""Enrolling TPM2 and FIDO2 for disk auto-unlock...$NC"

# Read LUKS encrypted partitions
if test -f /tmp/luks-devices
    for line in (cat /tmp/luks-devices)
        set parts (string split ":" $line)
        set mount_point $parts[1]
        set partition $parts[2]

        echo ""
        echo -e "$CYAN""Enrolling keys for $partition ($mount_point)$NC"

        # Try TPM2 enrollment
        if nixos-enter --root /mnt -- systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 "$partition"
            echo -e "$GREEN""✓ TPM2 enrolled for $partition$NC"

            # Set TPM2 slot as preferred (slot 1)
            nixos-enter --root /mnt -- cryptsetup config "$partition" --priority prefer --key-slot 1; or true
        else
            echo -e "$YELLOW""⚠ TPM2 enrollment failed (may not be available in VM)$NC"
        end

        # Ask how many FIDO2 keys to enroll
        echo ""
        read -P "How many FIDO2 keys do you want to enroll? [0]: " FIDO_COUNT
        if test -z "$FIDO_COUNT"
            set FIDO_COUNT 0
        end

        # Enroll FIDO2 keys
        for i in (seq 1 $FIDO_COUNT)
            echo -e "$YELLOW""Please insert FIDO2 key $i of $FIDO_COUNT for $partition and press Enter...$NC"
            read </dev/tty
            if nixos-enter --root /mnt -- systemd-cryptenroll --fido2-device=auto "$partition"
                echo -e "$GREEN""✓ FIDO2 key $i enrolled for $partition$NC"
            else
                echo -e "$YELLOW""⚠ FIDO2 key $i enrollment failed$NC"
            end
        end
    end
else
    echo -e "$YELLOW""⚠ No LUKS devices found for enrollment$NC"
end

echo -e "$GREEN""✓ Enrollment complete$NC"

# Set ownership
nixos-enter --root /mnt -- chown -R augusto:users /home/augusto

echo -e "$GREEN""✓ User environment complete$NC"

# ===== COMPLETION =====
rm -f /tmp/partition-info
rm -f /tmp/luks-devices

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
echo "  • NixOS config: ~/nixos (managed by home-manager)"
echo ""
echo -e "$YELLOW""IMPORTANT:$NC"
echo "  • Disk will auto-unlock via TPM2 (if available)"
echo "  • Fallback to FIDO2 key if TPM2 fails"
echo "  • Password fallback if FIDO2 unavailable"
echo "  • Login with username: $USERNAME"
echo ""
echo "To rebuild your system after making changes:"
echo "  cd ~/nixos && sudo nixos-rebuild switch --flake .#augusto"
echo ""

# Prompt for reboot or shell
while true
    echo -e "$YELLOW""What would you like to do?$NC"
    echo "  [R] Reboot now"
    echo "  [S] Drop to shell"
    echo ""
    read -P "Choice (R/S): " choice

    switch (string upper $choice)
        case R
            echo ""
            echo "Rebooting..."
            sleep 2
            reboot
        case S
            echo ""
            echo -e "$GREEN""Dropped to shell. Type 'exit' to return to installer menu.$NC"
            echo ""
            exit 0
        case '*'
            echo -e "$RED""Invalid choice. Please enter R or S.$NC"
            echo ""
    end
end
