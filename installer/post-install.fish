#!/usr/bin/env fish

# Post-install setup script.
# Run via nixos-enter after installation:
#   nixos-enter --root /mnt -- fish /etc/post-install.fish [FLAGS]
#
# Flags:
#   --tpm          Enroll TPM2 for LUKS auto-unlock
#   --fido         Enroll FIDO2 key(s) for LUKS unlock
#   --fingerprint  Reminder to enroll fingerprints after first login
#   --sops         Run sops-nix age key setup
#   --dotfiles     Clone dotfiles repo from GitHub
#   --media        Clone media repo from GitHub
#   --git-init     Initialize git in ~/nixos (for --extra-files installs)

set -l do_tpm false
set -l do_fido false
set -l do_fingerprint false
set -l do_sops false
set -l do_dotfiles false
set -l do_media false
set -l do_git_init false

for arg in $argv
    switch $arg
        case --tpm
            set do_tpm true
        case --fido
            set do_fido true
        case --fingerprint
            set do_fingerprint true
        case --sops
            set do_sops true
        case --dotfiles
            set do_dotfiles true
        case --media
            set do_media true
        case --git-init
            set do_git_init true
        case '*'
            echo "Unknown flag: $arg"
            echo "Usage: post-install.fish [--tpm] [--fido] [--fingerprint] [--sops] [--dotfiles] [--media] [--git-init]"
            exit 1
    end
end

# --- TPM2 enrollment ---
if test "$do_tpm" = true
    echo "=== TPM2 Enrollment ==="
    # Find LUKS devices
    for dev in (lsblk -lnp -o NAME,FSTYPE | grep crypto_LUKS | awk '{print $1}')
        echo "Enrolling TPM2 for $dev..."
        echo "You will be prompted for the LUKS passphrase."
        systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 "$dev"
        and echo "TPM2 enrolled for $dev"
        or echo "TPM2 enrollment failed for $dev (may not be available)"
    end
end

# --- FIDO2 enrollment ---
if test "$do_fido" = true
    echo "=== FIDO2 Enrollment ==="
    for dev in (lsblk -lnp -o NAME,FSTYPE | grep crypto_LUKS | awk '{print $1}')
        read -P "How many FIDO2 keys to enroll for $dev? [0]: " count
        test -z "$count"; and set count 0

        for i in (seq 1 $count)
            echo "Insert FIDO2 key $i of $count and press Enter..."
            read
            systemd-cryptenroll --fido2-device=auto "$dev"
            and echo "FIDO2 key $i enrolled for $dev"
            or echo "FIDO2 enrollment failed"
        end
    end
end

# --- SOPS age key setup ---
if test "$do_sops" = true
    echo "=== SOPS Age Key Setup ==="
    if test -f /home/augusto/nixos/modules/security/secrets/sops-setup.fish
        su augusto -c "fish /home/augusto/nixos/modules/security/secrets/sops-setup.fish"
    else
        echo "sops-setup.fish not found, skipping"
    end
end

# --- Clone dotfiles ---
if test "$do_dotfiles" = true
    echo "=== Cloning dotfiles ==="
    if not test -d /home/augusto/nixos/.git
        su augusto -c "git clone git@github.com:augustocdias/nixos.git /home/augusto/nixos"
    else
        echo "Dotfiles already present, skipping"
    end
end

# --- Clone media ---
if test "$do_media" = true
    echo "=== Cloning media ==="
    if not test -d /home/augusto/media/.git
        su augusto -c "git clone git@github.com:augustocdias/media.git /home/augusto/media"
    else
        echo "Media already present, skipping"
    end
end

# --- Git init (for --extra-files installs) ---
if test "$do_git_init" = true
    echo "=== Initializing git in ~/nixos ==="
    if not test -d /home/augusto/nixos/.git
        su augusto -c "cd /home/augusto/nixos && git init && git remote add origin git@github.com:augustocdias/nixos.git && git fetch origin && git reset --mixed origin/main"
    else
        echo "Git already initialized, skipping"
    end
end

# --- Fingerprint reminder ---
if test "$do_fingerprint" = true
    echo ""
    echo "=== Fingerprint Enrollment ==="
    echo "After first login, enroll fingerprints with:"
    echo "  fprintd-enroll"
    echo "  fprintd-enroll -f right-index-finger"
    echo ""
end

echo "=== Post-install complete ==="
