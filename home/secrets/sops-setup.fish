#!/usr/bin/env fish
# Setup age key for sops-nix on a new machine
# This script:
# 1. Generates an age key if it doesn't exist
# 2. Automatically updates .sops.yaml with the new key
# 3. Re-encrypts secrets with the new key (requires YubiKey on new machines)

set -l DOTFILES_DIR "$HOME/nixos"
set -l AGE_KEY_DIR "$HOME/.config/sops/age"
set -l AGE_KEY_FILE "$AGE_KEY_DIR/keys.txt"
set -l SOPS_CONFIG "$DOTFILES_DIR/.sops.yaml"
set -l SECRETS_FILE "$DOTFILES_DIR/home/secrets/env.yaml"

function info
    set_color green
    echo -n "[INFO] "
    set_color normal
    echo $argv
end

function warn
    set_color yellow
    echo -n "[WARN] "
    set_color normal
    echo $argv
end

function error
    set_color red
    echo -n "[ERROR] "
    set_color normal
    echo $argv
end

# Check dependencies
for cmd in age-keygen sops yq
    if not command -q $cmd
        error "$cmd not found. Please install it."
        exit 1
    end
end

# Step 1: Generate age key if it doesn't exist
if test -f "$AGE_KEY_FILE"
    warn "Age key already exists at $AGE_KEY_FILE"
else
    info "Generating new age key..."
    mkdir -p "$AGE_KEY_DIR"
    age-keygen -o "$AGE_KEY_FILE" 2>&1
    chmod 600 "$AGE_KEY_FILE"
    info "Age key generated at $AGE_KEY_FILE"
end

# Extract public key
set -l PUBLIC_KEY (grep "public key:" "$AGE_KEY_FILE" | awk '{print $4}')

if test -z "$PUBLIC_KEY"
    error "Failed to extract public key from $AGE_KEY_FILE"
    exit 1
end

info "Public key: $PUBLIC_KEY"

# Get hostname for the key alias
set -l HOSTNAME (hostname)
set -l KEY_ALIAS (string replace -a '-' '_' "$HOSTNAME")

# Step 2: Update .sops.yaml
if not test -f "$SOPS_CONFIG"
    error ".sops.yaml not found at $SOPS_CONFIG"
    exit 1
end

if grep -q "$PUBLIC_KEY" "$SOPS_CONFIG"
    info "Public key already in .sops.yaml"
else
    info "Adding key to .sops.yaml..."

    # Add the age key with anchor to the keys section
    set -l key_entry "&$KEY_ALIAS $PUBLIC_KEY"
    yq -i ".keys += [\"$key_entry\"]" "$SOPS_CONFIG"

    # Check if age array exists in creation_rules, if not create it
    set -l has_age (yq '.creation_rules[0].age' "$SOPS_CONFIG")
    if test "$has_age" = "null"
        # Create age array with the new key alias (use alias format)
        yq -i ".creation_rules[0].age = [alias(\"$KEY_ALIAS\")]" "$SOPS_CONFIG"
    else
        # Append to existing age array
        yq -i ".creation_rules[0].age += [alias(\"$KEY_ALIAS\")]" "$SOPS_CONFIG"
    end

    info "Updated .sops.yaml with new key"
end

# Step 3: Re-encrypt secrets with the new key
if not test -f "$SECRETS_FILE"
    error "Secrets file not found at $SECRETS_FILE"
    exit 1
end

info "Re-encrypting secrets with new key..."
info "This may require YubiKey touch if this is a new machine."
echo ""

cd "$DOTFILES_DIR"
if sops updatekeys -y "$SECRETS_FILE"
    info "Secrets re-encrypted successfully!"
    echo ""
    info "Next steps:"
    info "  1. Commit the updated .sops.yaml and secrets file"
    info "  2. Run: nixos-rebuild switch --flake .#"
    info "  3. The sops-nix service should now decrypt automatically"
else
    error "Failed to re-encrypt secrets."
    error "Make sure your YubiKey is plugged in and try again."
    exit 1
end
