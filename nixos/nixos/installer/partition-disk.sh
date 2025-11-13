#!/usr/bin/env bash
set -e

# Interactive disk partitioning script
# Called by install-script.sh with password argument

# Get password from argument
LUKS_PASSWORD="$1"

if [ -z "$LUKS_PASSWORD" ]; then
  echo "Error: No password provided"
  exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ===== DISK SELECTION =====
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Interactive Disk Partitioning       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Available disks:${NC}"
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
echo ""

while true; do
  read -p "Enter disk to install to (e.g., sda, nvme0n1): " DISK_NAME
  DISK="/dev/$DISK_NAME"

  if [ -b "$DISK" ]; then
    DISK_SIZE=$(lsblk -d -n -o SIZE "$DISK")
    echo -e "${GREEN}Selected: $DISK ($DISK_SIZE)${NC}"
    break
  fi
  echo -e "${RED}Error: $DISK is not a valid block device${NC}"
done

# ===== DISK WIPE =====
echo ""
echo -e "${RED}⚠️  WARNING: Do you want to WIPE this disk?${NC}"
echo "  [Y] Yes - Erase all data and create fresh GPT partition table"
echo "  [N] No  - Keep existing partitions and modify them"
echo ""

while true; do
  read -p "Choice (Y/N): " WIPE_CHOICE
  case "${WIPE_CHOICE^^}" in
    Y)
      echo ""
      echo -e "${YELLOW}Wiping disk and creating GPT partition table...${NC}"
      wipefs -af "$DISK"
      sgdisk -Z "$DISK"
      sgdisk -o "$DISK"  # Create new GPT table
      echo -e "${GREEN}✓ Disk wiped${NC}"
      break
      ;;
    N)
      echo -e "${YELLOW}Keeping existing partitions${NC}"
      break
      ;;
    *)
      echo -e "${RED}Invalid choice. Please enter Y or N.${NC}"
      ;;
  esac
done

# ===== INTERACTIVE PARTITIONING =====
echo ""
echo -e "${YELLOW}Opening cfdisk for manual partitioning...${NC}"
echo ""
echo -e "${CYAN}Guidelines:${NC}"
echo "  • ${CYAN}EFI System partition:${NC} ~512MB-1GB (Type: EFI System)"
echo "    ${YELLOW}Minimum: 100MB, Recommended: 512MB${NC}"
echo ""
echo "  • ${CYAN}Root (/) partition:${NC} System files and programs"
echo "    ${YELLOW}Minimum: 20GB, Recommended: 50GB+${NC}"
echo ""
echo "  • ${CYAN}/home partition (optional):${NC} User data"
echo "    ${YELLOW}Recommended: Use remaining space${NC}"
echo ""
echo "  • ${CYAN}Swap partition (optional):${NC} Type: Linux swap"
echo "    ${YELLOW}Optional: Will be auto-detected if created${NC}"
echo ""

echo "Press Enter when ready to open cfdisk..."
read

cfdisk "$DISK"

# ===== PARTITION DISCOVERY =====
echo ""
echo -e "${YELLOW}Scanning partitions on $DISK...${NC}"
sleep 1

# Refresh partition table
partprobe "$DISK" 2>/dev/null || true
sleep 1

# Get all partitions
declare -A PARTITIONS
declare -A PART_SIZES
declare -A PART_TYPES
PART_COUNT=0

for part in ${DISK}*; do
  if [ "$part" != "$DISK" ] && [ -b "$part" ]; then
    PART_COUNT=$((PART_COUNT + 1))
    PARTITIONS[$PART_COUNT]="$part"
    PART_SIZES[$PART_COUNT]=$(lsblk -n -o SIZE "$part" | head -1)

    # Detect partition type
    FSTYPE=$(lsblk -n -o FSTYPE "$part" | head -1)
    PARTTYPE=$(lsblk -n -o PARTTYPE "$part" | head -1)

    if [[ "$PARTTYPE" == *"c12a7328"* ]] || [[ "$FSTYPE" == "vfat" ]]; then
      PART_TYPES[$PART_COUNT]="EFI System"
    elif [[ "$PARTTYPE" == *"0657fd6d"* ]] || [[ "$FSTYPE" == "swap" ]]; then
      PART_TYPES[$PART_COUNT]="Linux swap"
    else
      PART_TYPES[$PART_COUNT]="Linux filesystem"
    fi
  fi
done

if [ $PART_COUNT -eq 0 ]; then
  echo -e "${RED}✗ No partitions found! Please create partitions first.${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}Found $PART_COUNT partition(s):${NC}"
for i in $(seq 1 $PART_COUNT); do
  echo "  [$i] ${PARTITIONS[$i]} - ${PART_SIZES[$i]} - ${PART_TYPES[$i]}"
done

# ===== VALIDATION =====
echo ""
echo -e "${YELLOW}Validating partitions...${NC}"

EFI_FOUND=false
LINUX_FOUND=false
SWAP_FOUND=false

for i in $(seq 1 $PART_COUNT); do
  if [ "${PART_TYPES[$i]}" = "EFI System" ]; then
    EFI_FOUND=true
  fi
  if [ "${PART_TYPES[$i]}" = "Linux filesystem" ]; then
    LINUX_FOUND=true
  fi
  if [ "${PART_TYPES[$i]}" = "Linux swap" ]; then
    SWAP_FOUND=true
  fi
done

if [ "$EFI_FOUND" = false ]; then
  echo -e "${RED}✗ No EFI partition found!${NC}"
  echo "You must create an EFI System partition for booting."
  exit 1
fi

if [ "$LINUX_FOUND" = false ]; then
  echo -e "${RED}✗ No Linux filesystem partition found!${NC}"
  echo "You must create at least one Linux filesystem partition for root (/)."
  exit 1
fi

echo -e "${GREEN}✓ EFI partition found${NC}"
echo -e "${GREEN}✓ Linux root partition found${NC}"

# Auto-detect swap configuration
if [ "$SWAP_FOUND" = true ]; then
  echo -e "${GREEN}✓ Swap partition found - will be used${NC}"
  SWAP_TYPE="partition"
else
  echo -e "${YELLOW}⚠ No swap partition found${NC}"
  SWAP_TYPE="none"
  SWAP_SIZE=""
fi

# ===== AUTO-SUGGEST ASSIGNMENTS =====
echo ""
echo -e "${CYAN}Suggested partition assignments:${NC}"

# Find EFI partition
BOOT_PART=""
for i in $(seq 1 $PART_COUNT); do
  if [ "${PART_TYPES[$i]}" = "EFI System" ]; then
    BOOT_PART="${PARTITIONS[$i]}"
    BOOT_NUM=$i
    break
  fi
done

# Find root partition (first Linux filesystem)
ROOT_PART=""
for i in $(seq 1 $PART_COUNT); do
  if [ "${PART_TYPES[$i]}" = "Linux filesystem" ]; then
    ROOT_PART="${PARTITIONS[$i]}"
    ROOT_NUM=$i
    break
  fi
done

# Count Linux filesystem partitions
LINUX_FS_COUNT=0
for i in $(seq 1 $PART_COUNT); do
  if [ "${PART_TYPES[$i]}" = "Linux filesystem" ]; then
    LINUX_FS_COUNT=$((LINUX_FS_COUNT + 1))
  fi
done

# Find home partition (second Linux filesystem if exists)
HOME_PART=""
HOME_NUM=""
if [ $LINUX_FS_COUNT -ge 2 ]; then
  COUNT=0
  for i in $(seq 1 $PART_COUNT); do
    if [ "${PART_TYPES[$i]}" = "Linux filesystem" ]; then
      COUNT=$((COUNT + 1))
      if [ $COUNT -eq 2 ]; then
        HOME_PART="${PARTITIONS[$i]}"
        HOME_NUM=$i
        break
      fi
    fi
  done
fi

# Find swap partition
SWAP_PART=""
SWAP_NUM=""
for i in $(seq 1 $PART_COUNT); do
  if [ "${PART_TYPES[$i]}" = "Linux swap" ]; then
    SWAP_PART="${PARTITIONS[$i]}"
    SWAP_NUM=$i
    # Get swap size in GB for reference
    SWAP_SIZE=$(lsblk -n -o SIZE "$SWAP_PART" | head -1 | sed 's/[^0-9.]//g' | cut -d. -f1)
    break
  fi
done

# Warn if more than 2 Linux filesystem partitions
if [ $LINUX_FS_COUNT -gt 2 ]; then
  echo ""
  echo -e "${YELLOW}⚠ Warning: More than 2 Linux filesystem partitions detected${NC}"
  echo "This installer only handles Boot (EFI), Root (/), Home (/home), and Swap."
  echo "Extra partitions will be ignored. Configure them manually after installation."
  echo ""
fi

echo "  Boot (EFI):   $BOOT_PART (${PART_SIZES[$BOOT_NUM]})"
echo "  Root (/):     $ROOT_PART (${PART_SIZES[$ROOT_NUM]})"
if [ -n "$HOME_PART" ]; then
  echo "  Home (/home): $HOME_PART (${PART_SIZES[$HOME_NUM]})"
fi
if [ -n "$SWAP_PART" ]; then
  echo "  Swap:         $SWAP_PART (${PART_SIZES[$SWAP_NUM]})"
fi

echo ""
read -p "Accept these assignments? (Y/N): " ACCEPT

if [[ "${ACCEPT^^}" != "Y" ]]; then
  # ===== MANUAL ASSIGNMENT =====
  echo ""
  echo -e "${CYAN}Manual partition assignment:${NC}"
  echo ""

  # Boot partition
  read -p "Boot partition (EFI) [$BOOT_NUM]: " BOOT_INPUT
  BOOT_INPUT=${BOOT_INPUT:-$BOOT_NUM}
  BOOT_PART="${PARTITIONS[$BOOT_INPUT]}"

  # Root partition
  read -p "Root partition (/) [$ROOT_NUM]: " ROOT_INPUT
  ROOT_INPUT=${ROOT_INPUT:-$ROOT_NUM}
  ROOT_PART="${PARTITIONS[$ROOT_INPUT]}"

  # Home partition (optional)
  echo ""
  echo "Assign home partition (optional, leave empty to skip):"
  for i in $(seq 1 $PART_COUNT); do
    if [ $i -ne $BOOT_INPUT ] && [ $i -ne $ROOT_INPUT ] && [ "${PART_TYPES[$i]}" = "Linux filesystem" ]; then
      echo "  [$i] ${PARTITIONS[$i]} (${PART_SIZES[$i]})"
    fi
  done
  read -p "Home partition (/home) [empty=none]: " HOME_INPUT
  if [ -n "$HOME_INPUT" ]; then
    HOME_PART="${PARTITIONS[$HOME_INPUT]}"
  else
    HOME_PART=""
  fi

  # Swap assignment
  if [ -n "$SWAP_PART" ]; then
    echo ""
    read -p "Use $SWAP_PART as swap? (Y/N): " USE_SWAP
    if [[ "${USE_SWAP^^}" != "Y" ]]; then
      SWAP_PART=""
    fi
  fi
fi

# ===== FILESYSTEM TYPE SELECTION =====
echo ""
echo -e "${CYAN}Filesystem type selection:${NC}"
echo ""
echo "Choose filesystem type for partitions:"
echo "  [1] ext4      - Stable, proven (recommended)"
echo "  [2] btrfs     - Modern, snapshots, compression"
echo "  [3] xfs       - High performance, large files"
echo "  [4] f2fs      - Flash-optimized (for SSDs)"
echo ""

# Function to prompt for filesystem type
choose_fs() {
  local partition=$1
  local mount_point=$2
  local default="1"

  while true; do
    read -p "Filesystem for $partition ($mount_point) [1]: " fs_choice
    fs_choice=${fs_choice:-$default}

    case "$fs_choice" in
      1) echo "ext4"; return ;;
      2) echo "btrfs"; return ;;
      3) echo "xfs"; return ;;
      4) echo "f2fs"; return ;;
      *)
        echo -e "${RED}Invalid choice. Please enter 1-4.${NC}"
        ;;
    esac
  done
}

# Root filesystem
ROOT_FS=$(choose_fs "$ROOT_PART" "/")
echo -e "${GREEN}Root will use $ROOT_FS${NC}"

# Home filesystem
HOME_FS=""
if [ -n "$HOME_PART" ]; then
  HOME_FS=$(choose_fs "$HOME_PART" "/home")
  echo -e "${GREEN}/home will use $HOME_FS${NC}"
fi

# ===== FORMAT CONFIRMATION =====
echo ""
echo -e "${RED}⚠️  FINAL CONFIRMATION${NC}"
echo ""
echo "The following operations will be performed:"
echo "  • Format $BOOT_PART as FAT32 (EFI)"
echo "  • Encrypt and format $ROOT_PART as $ROOT_FS (root)"
if [ -n "$HOME_PART" ]; then
  echo "  • Encrypt and format $HOME_PART as $HOME_FS (/home)"
fi
if [ -n "$SWAP_PART" ]; then
  echo "  • Format $SWAP_PART as swap"
fi
echo ""
echo -e "${RED}This will ERASE ALL DATA on these partitions!${NC}"
echo ""

while true; do
  read -p "Type 'yes' to continue: " CONFIRM
  if [ "$CONFIRM" = "yes" ]; then
    break
  fi
  echo -e "${RED}Please type 'yes' exactly to confirm${NC}"
done

# ===== BUILD MOUNT STRUCTURE =====
# Only handle root and optionally home
declare -A ALL_MOUNTS  # mount_point -> partition
declare -A ALL_FS      # mount_point -> filesystem_type

ALL_MOUNTS["/"]="$ROOT_PART"
ALL_FS["/"]="$ROOT_FS"

if [ -n "$HOME_PART" ]; then
  ALL_MOUNTS["/home"]="$HOME_PART"
  ALL_FS["/home"]="$HOME_FS"
fi

# ===== LUKS ENCRYPTION & FORMAT =====
echo ""
echo -e "${YELLOW}Setting up LUKS2 encryption and formatting partitions...${NC}"

# Helper function to format partition based on filesystem type
format_partition() {
  local device=$1
  local fs=$2

  case "$fs" in
    ext4)
      mkfs.ext4 -F "$device"
      ;;
    btrfs)
      mkfs.btrfs -f "$device"
      ;;
    xfs)
      mkfs.xfs -f "$device"
      ;;
    f2fs)
      mkfs.f2fs -f "$device"
      ;;
    *)
      echo -e "${RED}Unknown filesystem type: $fs${NC}"
      exit 1
      ;;
  esac
}

# Format boot partition (no encryption)
wipefs -a "$BOOT_PART" >/dev/null 2>&1 || true
mkfs.fat -F32 "$BOOT_PART"
echo -e "${GREEN}✓ $BOOT_PART formatted as FAT32${NC}"

# Encrypt and format all Linux filesystem partitions
declare -A LUKS_DEVICES  # mount_point -> /dev/mapper/cryptX

for mount_point in $(echo "${!ALL_MOUNTS[@]}" | tr ' ' '\n' | sort); do
  partition="${ALL_MOUNTS[$mount_point]}"
  fs="${ALL_FS[$mount_point]}"

  # Generate LUKS name based on mount point
  if [ "$mount_point" = "/" ]; then
    luks_name="cryptroot"
  else
    # Strip leading slash: /home -> crypthome, /var -> cryptvar, etc.
    luks_name="crypt${mount_point#/}"
  fi

  # Wipe any existing signatures
  wipefs -a "$partition" >/dev/null 2>&1 || true

  # Encrypt and format
  printf "%s" "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 -q "$partition" --key-file=-
  printf "%s" "$LUKS_PASSWORD" | cryptsetup open "$partition" "$luks_name" --key-file=-
  format_partition "/dev/mapper/$luks_name" "$fs"
  echo -e "${GREEN}✓ $partition encrypted and formatted as $fs (${mount_point})${NC}"

  LUKS_DEVICES["$mount_point"]="/dev/mapper/$luks_name"
done

# Format swap (no encryption)
if [ -n "$SWAP_PART" ]; then
  wipefs -a "$SWAP_PART" >/dev/null 2>&1 || true
  mkswap "$SWAP_PART"
  echo -e "${GREEN}✓ $SWAP_PART initialized as swap${NC}"
fi

echo ""
echo -e "${YELLOW}Mounting filesystems...${NC}"

# Mount root first
mount "${LUKS_DEVICES[/]}" /mnt
echo -e "${GREEN}✓ Mounted ${LUKS_DEVICES[/]} on /mnt${NC}"

# Mount boot
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot
echo -e "${GREEN}✓ Mounted $BOOT_PART on /mnt/boot${NC}"

# Mount all other encrypted partitions
for mount_point in $(echo "${!LUKS_DEVICES[@]}" | tr ' ' '\n' | sort); do
  if [ "$mount_point" != "/" ]; then
    mkdir -p "/mnt$mount_point"
    mount "${LUKS_DEVICES[$mount_point]}" "/mnt$mount_point"
    echo -e "${GREEN}✓ Mounted ${LUKS_DEVICES[$mount_point]} on /mnt$mount_point${NC}"
  fi
done

# Enable swap
if [ -n "$SWAP_PART" ]; then
  swapon "$SWAP_PART"
  echo -e "${GREEN}✓ Swap enabled${NC}"
fi

# ===== SAVE PARTITION INFO =====
# Save for use by install script
cat > /tmp/partition-info <<EOF
BOOT_PART=$BOOT_PART
ROOT_PART=$ROOT_PART
ROOT_FS=$ROOT_FS
HOME_PART=$HOME_PART
HOME_FS=$HOME_FS
SWAP_PART=$SWAP_PART
SWAP_TYPE=$SWAP_TYPE
SWAP_SIZE=$SWAP_SIZE
DISK=$DISK
EOF

# Save LUKS encrypted partitions for TPM2/FIDO2 enrollment
# Format: mount_point:partition_device
for mount_point in "${!ALL_MOUNTS[@]}"; do
  echo "$mount_point:${ALL_MOUNTS[$mount_point]}" >> /tmp/luks-devices
done

echo ""
echo -e "${GREEN}✓ Disk setup complete!${NC}"
echo ""
