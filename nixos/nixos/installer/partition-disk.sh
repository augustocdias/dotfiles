#!/usr/bin/env bash
set -e

# Interactive disk partitioning script
# Called by install-script.sh

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

# ===== SWAP CONFIGURATION =====
echo ""
echo -e "${CYAN}Swap configuration:${NC}"
echo "  [1] No swap (can add swapfile later)"
echo "  [2] Swap partition (you'll create it in cfdisk)"
echo "  [3] Swapfile (created after install)"
echo ""

SWAP_TYPE=""
SWAP_SIZE=""

while true; do
  read -p "Choice (1-3): " SWAP_CHOICE
  case "$SWAP_CHOICE" in
    1)
      SWAP_TYPE="none"
      echo -e "${GREEN}No swap will be configured${NC}"
      break
      ;;
    2)
      SWAP_TYPE="partition"
      while true; do
        read -p "Swap size in GB (e.g., 8): " SWAP_SIZE
        if [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]]; then
          echo -e "${GREEN}Will look for ${SWAP_SIZE}GB swap partition${NC}"
          break
        fi
        echo -e "${RED}Please enter a valid number${NC}"
      done
      break
      ;;
    3)
      SWAP_TYPE="file"
      while true; do
        read -p "Swapfile size in GB (e.g., 8): " SWAP_SIZE
        if [[ "$SWAP_SIZE" =~ ^[0-9]+$ ]]; then
          echo -e "${GREEN}Will create ${SWAP_SIZE}GB swapfile after install${NC}"
          break
        fi
        echo -e "${RED}Please enter a valid number${NC}"
      done
      break
      ;;
    *)
      echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${NC}"
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

if [ "$SWAP_TYPE" = "partition" ]; then
  echo "  • ${CYAN}Swap partition:${NC} ${SWAP_SIZE}GB (Type: Linux swap)"
  echo ""
fi

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

if [ "$SWAP_TYPE" = "partition" ] && [ "$SWAP_FOUND" = true ]; then
  echo -e "${GREEN}✓ Swap partition found${NC}"
elif [ "$SWAP_TYPE" = "partition" ] && [ "$SWAP_FOUND" = false ]; then
  echo -e "${YELLOW}⚠ Swap partition not found (you chose swap partition option)${NC}"
  echo "Continuing anyway..."
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

# Find home partition (second Linux filesystem if exists)
HOME_PART=""
HOME_NUM=""
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

# Find swap partition
SWAP_PART=""
SWAP_NUM=""
for i in $(seq 1 $PART_COUNT); do
  if [ "${PART_TYPES[$i]}" = "Linux swap" ]; then
    SWAP_PART="${PARTITIONS[$i]}"
    SWAP_NUM=$i
    break
  fi
done

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

  # Build list of unassigned partitions
  declare -a UNASSIGNED
  for i in $(seq 1 $PART_COUNT); do
    if [ $i -ne $BOOT_INPUT ] && [ $i -ne $ROOT_INPUT ] && [ "${PART_TYPES[$i]}" != "Linux swap" ]; then
      UNASSIGNED+=($i)
    fi
  done

  # Assign additional partitions
  HOME_PART=""
  declare -A EXTRA_MOUNTS

  for idx in "${UNASSIGNED[@]}"; do
    echo ""
    echo "Additional partition found: ${PARTITIONS[$idx]} (${PART_SIZES[$idx]})"
    echo "Mount ${PARTITIONS[$idx]} at:"
    echo "  [1] /home"
    echo "  [2] /var"
    echo "  [3] /tmp"
    echo "  [4] Custom path"
    echo "  [5] Don't mount (skip)"
    echo ""

    read -p "Choice: " MOUNT_CHOICE
    case "$MOUNT_CHOICE" in
      1)
        HOME_PART="${PARTITIONS[$idx]}"
        echo -e "${GREEN}Assigned to /home${NC}"
        ;;
      2)
        EXTRA_MOUNTS["/var"]="${PARTITIONS[$idx]}"
        echo -e "${GREEN}Assigned to /var${NC}"
        ;;
      3)
        EXTRA_MOUNTS["/tmp"]="${PARTITIONS[$idx]}"
        echo -e "${GREEN}Assigned to /tmp${NC}"
        ;;
      4)
        read -p "Enter mount point (e.g., /data): " CUSTOM_MOUNT
        EXTRA_MOUNTS["$CUSTOM_MOUNT"]="${PARTITIONS[$idx]}"
        echo -e "${GREEN}Assigned to $CUSTOM_MOUNT${NC}"
        ;;
      5)
        echo -e "${YELLOW}Skipped${NC}"
        ;;
      *)
        echo -e "${RED}Invalid choice, skipping${NC}"
        ;;
    esac
  done

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

# Extra mount filesystems
declare -A EXTRA_FS
for mount in "${!EXTRA_MOUNTS[@]}"; do
  EXTRA_FS["$mount"]=$(choose_fs "${EXTRA_MOUNTS[$mount]}" "$mount")
  echo -e "${GREEN}$mount will use ${EXTRA_FS[$mount]}${NC}"
done

# ===== FORMAT CONFIRMATION =====
echo ""
echo -e "${RED}⚠️  FINAL CONFIRMATION${NC}"
echo ""
echo "The following operations will be performed:"
echo "  • Format $BOOT_PART as FAT32 (EFI)"
echo "  • Format $ROOT_PART as $ROOT_FS (root)"
if [ -n "$HOME_PART" ]; then
  echo "  • Format $HOME_PART as $HOME_FS (/home)"
fi
for mount in "${!EXTRA_MOUNTS[@]}"; do
  echo "  • Format ${EXTRA_MOUNTS[$mount]} as ${EXTRA_FS[$mount]} ($mount)"
done
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

# ===== FORMAT & MOUNT =====
echo ""
echo -e "${YELLOW}Formatting partitions...${NC}"

# Helper function to format partition based on filesystem type
format_partition() {
  local part=$1
  local fs=$2

  case "$fs" in
    ext4)
      mkfs.ext4 -F "$part"
      ;;
    btrfs)
      mkfs.btrfs -f "$part"
      ;;
    xfs)
      mkfs.xfs -f "$part"
      ;;
    f2fs)
      mkfs.f2fs -f "$part"
      ;;
    *)
      echo -e "${RED}Unknown filesystem type: $fs${NC}"
      exit 1
      ;;
  esac
}

mkfs.fat -F32 "$BOOT_PART"
echo -e "${GREEN}✓ $BOOT_PART formatted as FAT32${NC}"

format_partition "$ROOT_PART" "$ROOT_FS"
echo -e "${GREEN}✓ $ROOT_PART formatted as $ROOT_FS${NC}"

if [ -n "$HOME_PART" ]; then
  format_partition "$HOME_PART" "$HOME_FS"
  echo -e "${GREEN}✓ $HOME_PART formatted as $HOME_FS${NC}"
fi

for mount in "${!EXTRA_MOUNTS[@]}"; do
  format_partition "${EXTRA_MOUNTS[$mount]}" "${EXTRA_FS[$mount]}"
  echo -e "${GREEN}✓ ${EXTRA_MOUNTS[$mount]} formatted as ${EXTRA_FS[$mount]}${NC}"
done

if [ -n "$SWAP_PART" ]; then
  mkswap "$SWAP_PART"
  echo -e "${GREEN}✓ $SWAP_PART initialized as swap${NC}"
fi

echo ""
echo -e "${YELLOW}Mounting filesystems...${NC}"

mount "$ROOT_PART" /mnt
echo -e "${GREEN}✓ Mounted $ROOT_PART on /mnt${NC}"

mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot
echo -e "${GREEN}✓ Mounted $BOOT_PART on /mnt/boot${NC}"

if [ -n "$HOME_PART" ]; then
  mkdir -p /mnt/home
  mount "$HOME_PART" /mnt/home
  echo -e "${GREEN}✓ Mounted $HOME_PART on /mnt/home${NC}"
fi

for mount in "${!EXTRA_MOUNTS[@]}"; do
  mkdir -p "/mnt$mount"
  mount "${EXTRA_MOUNTS[$mount]}" "/mnt$mount"
  echo -e "${GREEN}✓ Mounted ${EXTRA_MOUNTS[$mount]} on /mnt$mount${NC}"
done

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

# Save extra mounts and their filesystems
if [ ${#EXTRA_MOUNTS[@]} -gt 0 ]; then
  for mount in "${!EXTRA_MOUNTS[@]}"; do
    echo "$mount=${EXTRA_MOUNTS[$mount]}:${EXTRA_FS[$mount]}" >> /tmp/extra-mounts
  done
fi

echo ""
echo -e "${GREEN}✓ Disk setup complete!${NC}"
echo ""
