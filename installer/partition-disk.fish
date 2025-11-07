#!/usr/bin/env fish
# Interactive disk partitioning script
# Called by install-script.fish with password argument

set LUKS_PASSWORD $argv[1]

if test -z "$LUKS_PASSWORD"
    echo "Error: No password provided"
    exit 1
end

# Colors
set RED '\033[0;31m'
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set BLUE '\033[0;34m'
set CYAN '\033[0;36m'
set NC '\033[0m'

# ===== DISK SELECTION =====
echo ""
echo -e "$BLUE╔════════════════════════════════════════════╗$NC"
echo -e "$BLUE║       Interactive Disk Partitioning       ║$NC"
echo -e "$BLUE╚════════════════════════════════════════════╝$NC"
echo ""
echo -e "{$YELLOW}Available disks:$NC"
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
echo ""

while true
    read -P "Enter disk to install to (e.g., sda, nvme0n1): " DISK_NAME
    set DISK "/dev/$DISK_NAME"

    if test -b "$DISK"
        set DISK_SIZE (lsblk -d -n -o SIZE "$DISK")
        echo -e "$GREEN""Selected: $DISK ($DISK_SIZE)$NC"
        break
    end
    echo -e "$RED""Error: $DISK is not a valid block device$NC"
end

# ===== DISK WIPE =====
echo ""
echo -e "$RED⚠️  WARNING: Do you want to WIPE this disk?$NC"
echo "  [Y] Yes - Erase all data and create fresh GPT partition table"
echo "  [N] No  - Keep existing partitions and modify them"
echo ""

while true
    read -P "Choice (Y/N): " WIPE_CHOICE
    switch (string upper $WIPE_CHOICE)
        case Y
            echo ""
            echo -e "$YELLOW""Wiping disk and creating GPT partition table...$NC"
            wipefs -af "$DISK"
            sgdisk -Z "$DISK"
            sgdisk -o "$DISK"
            echo -e "$GREEN""✓ Disk wiped$NC"
            break
        case N
            echo -e "$YELLOW""Keeping existing partitions$NC"
            break
        case '*'
            echo -e "$RED""Invalid choice. Please enter Y or N.$NC"
    end
end

# ===== INTERACTIVE PARTITIONING =====
echo ""
echo -e "$YELLOW""Opening cfdisk for manual partitioning...$NC"
echo ""
echo -e "$CYAN""Guidelines:$NC"
echo "  • $CYAN""EFI System partition:$NC ~512MB-1GB (Type: EFI System)"
echo "    $YELLOW""Minimum: 100MB, Recommended: 512MB$NC"
echo ""
echo "  • $CYAN""Root (/) partition:$NC System files and programs"
echo "    $YELLOW""Minimum: 20GB, Recommended: 50GB+$NC"
echo ""
echo "  • $CYAN""/home partition (optional):$NC User data"
echo "    $YELLOW""Recommended: Use remaining space$NC"
echo ""
echo "  • $CYAN""Swap partition (optional):$NC Type: Linux swap"
echo "    $YELLOW""Optional: Will be auto-detected if created$NC"
echo ""

read -P "Press Enter when ready to open cfdisk..."

cfdisk "$DISK"

# ===== PARTITION DISCOVERY =====
echo ""
echo -e "$YELLOW""Scanning partitions on $DISK...$NC"
sleep 1

# Refresh partition table
partprobe "$DISK" 2>/dev/null; or true
sleep 1

# Get all partitions
set -g PARTITIONS
set -g PART_SIZES
set -g PART_TYPES
set -g PART_COUNT 0

for part in $DISK*
    if test "$part" != "$DISK"; and test -b "$part"
        set PART_COUNT (math $PART_COUNT + 1)
        set -a PARTITIONS "$part"
        set -a PART_SIZES (lsblk -n -o SIZE "$part" | head -1)

        # Detect partition type
        set FSTYPE (lsblk -n -o FSTYPE "$part" | head -1)
        set PARTTYPE (lsblk -n -o PARTTYPE "$part" | head -1)

        if string match -q "*c12a7328*" "$PARTTYPE"; or test "$FSTYPE" = vfat
            set -a PART_TYPES "EFI System"
        else if string match -q "*0657fd6d*" "$PARTTYPE"; or test "$FSTYPE" = swap
            set -a PART_TYPES "Linux swap"
        else
            set -a PART_TYPES "Linux filesystem"
        end
    end
end

if test $PART_COUNT -eq 0
    echo -e "$RED""✗ No partitions found! Please create partitions first.$NC"
    exit 1
end

echo ""
echo -e "$GREEN""Found $PART_COUNT partition(s):$NC"
for i in (seq 1 $PART_COUNT)
    echo "  [$i] $PARTITIONS[$i] - $PART_SIZES[$i] - $PART_TYPES[$i]"
end

# ===== VALIDATION =====
echo ""
echo -e "$YELLOW""Validating partitions...$NC"

set EFI_FOUND false
set LINUX_FOUND false
set SWAP_FOUND false

for i in (seq 1 $PART_COUNT)
    if test "$PART_TYPES[$i]" = "EFI System"
        set EFI_FOUND true
    end
    if test "$PART_TYPES[$i]" = "Linux filesystem"
        set LINUX_FOUND true
    end
    if test "$PART_TYPES[$i]" = "Linux swap"
        set SWAP_FOUND true
    end
end

if test "$EFI_FOUND" = false
    echo -e "$RED""✗ No EFI partition found!$NC"
    echo "You must create an EFI System partition for booting."
    exit 1
end

if test "$LINUX_FOUND" = false
    echo -e "$RED""✗ No Linux filesystem partition found!$NC"
    echo "You must create at least one Linux filesystem partition for root (/)."
    exit 1
end

echo -e "$GREEN""✓ EFI partition found$NC"
echo -e "$GREEN""✓ Linux root partition found$NC"

# Auto-detect swap configuration
if test "$SWAP_FOUND" = true
    echo -e "$GREEN""✓ Swap partition found - will be used$NC"
    set SWAP_TYPE partition
else
    echo -e "$YELLOW""⚠ No swap partition found$NC"
    set SWAP_TYPE none
    set SWAP_SIZE ""
end

# ===== AUTO-SUGGEST ASSIGNMENTS =====
echo ""
echo -e "$CYAN""Suggested partition assignments:$NC"

# Find EFI partition
set BOOT_PART ""
set BOOT_NUM 0
for i in (seq 1 $PART_COUNT)
    if test "$PART_TYPES[$i]" = "EFI System"
        set BOOT_PART "$PARTITIONS[$i]"
        set BOOT_NUM $i
        break
    end
end

# Find root partition (first Linux filesystem)
set ROOT_PART ""
set ROOT_NUM 0
for i in (seq 1 $PART_COUNT)
    if test "$PART_TYPES[$i]" = "Linux filesystem"
        set ROOT_PART "$PARTITIONS[$i]"
        set ROOT_NUM $i
        break
    end
end

# Count Linux filesystem partitions
set LINUX_FS_COUNT 0
for i in (seq 1 $PART_COUNT)
    if test "$PART_TYPES[$i]" = "Linux filesystem"
        set LINUX_FS_COUNT (math $LINUX_FS_COUNT + 1)
    end
end

# Find home partition (second Linux filesystem if exists)
set HOME_PART ""
set HOME_NUM 0
if test $LINUX_FS_COUNT -ge 2
    set COUNT 0
    for i in (seq 1 $PART_COUNT)
        if test "$PART_TYPES[$i]" = "Linux filesystem"
            set COUNT (math $COUNT + 1)
            if test $COUNT -eq 2
                set HOME_PART "$PARTITIONS[$i]"
                set HOME_NUM $i
                break
            end
        end
    end
end

# Find swap partition
set SWAP_PART ""
set SWAP_NUM 0
for i in (seq 1 $PART_COUNT)
    if test "$PART_TYPES[$i]" = "Linux swap"
        set SWAP_PART "$PARTITIONS[$i]"
        set SWAP_NUM $i
        set SWAP_SIZE (lsblk -n -o SIZE "$SWAP_PART" | head -1 | sed 's/[^0-9.]//g' | cut -d. -f1)
        break
    end
end

# Warn if more than 2 Linux filesystem partitions
if test $LINUX_FS_COUNT -gt 2
    echo ""
    echo -e "$YELLOW""⚠ Warning: More than 2 Linux filesystem partitions detected$NC"
    echo "This installer only handles Boot (EFI), Root (/), Home (/home), and Swap."
    echo "Extra partitions will be ignored. Configure them manually after installation."
    echo ""
end

echo "  Boot (EFI):   $BOOT_PART ($PART_SIZES[$BOOT_NUM])"
echo "  Root (/):     $ROOT_PART ($PART_SIZES[$ROOT_NUM])"
if test -n "$HOME_PART"
    echo "  Home (/home): $HOME_PART ($PART_SIZES[$HOME_NUM])"
end
if test -n "$SWAP_PART"
    echo "  Swap:         $SWAP_PART ($PART_SIZES[$SWAP_NUM])"
end

echo ""
read -P "Accept these assignments? (Y/N): " ACCEPT

if test (string upper "$ACCEPT") != Y
    # ===== MANUAL ASSIGNMENT =====
    echo ""
    echo -e "$CYAN""Manual partition assignment:$NC"
    echo ""

    # Boot partition
    read -P "Boot partition (EFI) [$BOOT_NUM]: " BOOT_INPUT
    if test -z "$BOOT_INPUT"
        set BOOT_INPUT $BOOT_NUM
    end
    set BOOT_PART "$PARTITIONS[$BOOT_INPUT]"

    # Root partition
    read -P "Root partition (/) [$ROOT_NUM]: " ROOT_INPUT
    if test -z "$ROOT_INPUT"
        set ROOT_INPUT $ROOT_NUM
    end
    set ROOT_PART "$PARTITIONS[$ROOT_INPUT]"

    # Home partition (optional)
    echo ""
    echo "Assign home partition (optional, leave empty to skip):"
    for i in (seq 1 $PART_COUNT)
        if test $i -ne $BOOT_INPUT; and test $i -ne $ROOT_INPUT; and test "$PART_TYPES[$i]" = "Linux filesystem"
            echo "  [$i] $PARTITIONS[$i] ($PART_SIZES[$i])"
        end
    end
    read -P "Home partition (/home) [empty=none]: " HOME_INPUT
    if test -n "$HOME_INPUT"
        set HOME_PART "$PARTITIONS[$HOME_INPUT]"
    else
        set HOME_PART ""
    end

    # Swap assignment
    if test -n "$SWAP_PART"
        echo ""
        read -P "Use $SWAP_PART as swap? (Y/N): " USE_SWAP
        if test (string upper "$USE_SWAP") != Y
            set SWAP_PART ""
        end
    end
end

# ===== FILESYSTEM TYPE SELECTION =====
echo ""
echo -e "$CYAN""Filesystem type selection:$NC"
echo ""
echo "Choose filesystem type for partitions:"
echo "  [1] ext4      - Stable, proven (recommended)"
echo "  [2] btrfs     - Modern, snapshots, compression"
echo "  [3] xfs       - High performance, large files"
echo "  [4] f2fs      - Flash-optimized (for SSDs)"
echo ""

# Function to prompt for filesystem type
function choose_fs
    set partition $argv[1]
    set mount_point $argv[2]

    while true
        read -P "Filesystem for $partition ($mount_point) [1]: " fs_choice
        if test -z "$fs_choice"
            set fs_choice 1
        end

        switch $fs_choice
            case 1
                echo ext4
                return
            case 2
                echo btrfs
                return
            case 3
                echo xfs
                return
            case 4
                echo f2fs
                return
            case '*'
                echo -e "$RED""Invalid choice. Please enter 1-4.$NC" >&2
        end
    end
end

# Root filesystem
set ROOT_FS (choose_fs "$ROOT_PART" "/")
echo -e "$GREEN""Root will use $ROOT_FS$NC"

# Home filesystem
set HOME_FS ""
if test -n "$HOME_PART"
    set HOME_FS (choose_fs "$HOME_PART" "/home")
    echo -e "$GREEN""/home will use $HOME_FS$NC"
end

# ===== FORMAT CONFIRMATION =====
echo ""
echo -e "$RED""⚠️  FINAL CONFIRMATION$NC"
echo ""
echo "The following operations will be performed:"
echo "  • Format $BOOT_PART as FAT32 (EFI)"
echo "  • Encrypt and format $ROOT_PART as $ROOT_FS (root)"
if test -n "$HOME_PART"
    echo "  • Encrypt and format $HOME_PART as $HOME_FS (/home)"
end
if test -n "$SWAP_PART"
    echo "  • Format $SWAP_PART as swap"
end
echo ""
echo -e "$RED""This will ERASE ALL DATA on these partitions!$NC"
echo ""

while true
    read -P "Type 'yes' to continue: " CONFIRM
    if test "$CONFIRM" = yes
        break
    end
    echo -e "$RED""Please type 'yes' exactly to confirm$NC"
end

# ===== BUILD MOUNT STRUCTURE =====
set -g MOUNT_POINTS /
set -g MOUNT_PARTITIONS "$ROOT_PART"
set -g MOUNT_FS "$ROOT_FS"

if test -n "$HOME_PART"
    set -a MOUNT_POINTS /home
    set -a MOUNT_PARTITIONS "$HOME_PART"
    set -a MOUNT_FS "$HOME_FS"
end

# ===== HELPER FUNCTION =====
function format_partition
    set device $argv[1]
    set fs $argv[2]

    switch $fs
        case ext4
            mkfs.ext4 -F "$device"
        case btrfs
            mkfs.btrfs -f "$device"
        case xfs
            mkfs.xfs -f "$device"
        case f2fs
            mkfs.f2fs -f "$device"
        case '*'
            echo -e "$RED""Unknown filesystem type: $fs$NC"
            exit 1
    end
end

# ===== LUKS ENCRYPTION & FORMAT =====
echo ""
echo -e "$YELLOW""Setting up LUKS2 encryption and formatting partitions...$NC"

# Format boot partition (no encryption)
wipefs -a "$BOOT_PART" >/dev/null 2>&1; or true
mkfs.fat -F32 "$BOOT_PART"
echo -e "$GREEN""✓ $BOOT_PART formatted as FAT32$NC"

# Encrypt and format all Linux filesystem partitions
set -g LUKS_MOUNT_POINTS
set -g LUKS_DEVICES

for i in (seq 1 (count $MOUNT_POINTS))
    set mount_point $MOUNT_POINTS[$i]
    set partition $MOUNT_PARTITIONS[$i]
    set fs $MOUNT_FS[$i]

    # Generate LUKS name based on mount point
    if test "$mount_point" = /
        set luks_name cryptroot
    else
        set luks_name "crypt"(string replace -a "/" "" "$mount_point")
    end

    # Wipe any existing signatures
    wipefs -a "$partition" >/dev/null 2>&1; or true

    # Encrypt and format
    printf "%s" "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 -q "$partition" --key-file=-
    printf "%s" "$LUKS_PASSWORD" | cryptsetup open "$partition" "$luks_name" --key-file=-
    format_partition "/dev/mapper/$luks_name" "$fs"
    echo -e "$GREEN""✓ $partition encrypted and formatted as $fs ($mount_point)$NC"

    set -a LUKS_MOUNT_POINTS "$mount_point"
    set -a LUKS_DEVICES "/dev/mapper/$luks_name"
end

# Format swap (no encryption)
if test -n "$SWAP_PART"
    wipefs -a "$SWAP_PART" >/dev/null 2>&1; or true
    mkswap "$SWAP_PART"
    echo -e "$GREEN""✓ $SWAP_PART initialized as swap$NC"
end

echo ""
echo -e "$YELLOW""Mounting filesystems...$NC"

# Find root device
for i in (seq 1 (count $LUKS_MOUNT_POINTS))
    if test "$LUKS_MOUNT_POINTS[$i]" = /
        mount "$LUKS_DEVICES[$i]" /mnt
        echo -e "$GREEN""✓ Mounted $LUKS_DEVICES[$i] on /mnt$NC"
        break
    end
end

# Mount boot
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot
echo -e "$GREEN""✓ Mounted $BOOT_PART on /mnt/boot$NC"

# Mount all other encrypted partitions
for i in (seq 1 (count $LUKS_MOUNT_POINTS))
    set mount_point $LUKS_MOUNT_POINTS[$i]
    if test "$mount_point" != /
        mkdir -p "/mnt$mount_point"
        mount "$LUKS_DEVICES[$i]" "/mnt$mount_point"
        echo -e "$GREEN""✓ Mounted $LUKS_DEVICES[$i] on /mnt$mount_point$NC"
    end
end

# Enable swap
if test -n "$SWAP_PART"
    swapon "$SWAP_PART"
    echo -e "$GREEN""✓ Swap enabled$NC"
end

# ===== SAVE PARTITION INFO =====
echo "BOOT_PART=$BOOT_PART
ROOT_PART=$ROOT_PART
ROOT_FS=$ROOT_FS
HOME_PART=$HOME_PART
HOME_FS=$HOME_FS
SWAP_PART=$SWAP_PART
SWAP_TYPE=$SWAP_TYPE
SWAP_SIZE=$SWAP_SIZE
DISK=$DISK" >/tmp/partition-info

# Save LUKS encrypted partitions for TPM2/FIDO2 enrollment
rm -f /tmp/luks-devices
for i in (seq 1 (count $MOUNT_POINTS))
    echo "$MOUNT_POINTS[$i]:$MOUNT_PARTITIONS[$i]" >>/tmp/luks-devices
end

echo ""
echo -e "$GREEN""✓ Disk setup complete!$NC"
echo ""
