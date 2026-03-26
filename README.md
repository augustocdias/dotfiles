# Personal NixOS Configuration

Dendritic NixOS configuration using [Den](https://github.com/vic/den) + [flake-parts](https://flake.parts) + [flake-file](https://github.com/vic/flake-file).

## Hosts

| Host | Platform | Profile | Description |
|------|----------|---------|-------------|
| `laptop` | x86_64-linux | workstation | Hyprland desktop with DMS shell |
| `raspi` | aarch64-linux | server | Headless Raspberry Pi (planned) |

## Building the Installer ISO

```bash
nix build .#installer
```

## Installing NixOS

### Option A: Remote install with nixos-anywhere

From an existing machine, targeting a machine booted with the custom ISO (or any Linux with SSH):

```bash
# 1. Boot target machine with ISO, note its IP

# 2. Prepare extra-files
EXTRA=$(mktemp -d)
cp -r ~/nixos "$EXTRA/home/augusto/nixos"
mkdir -p "$EXTRA/etc/nixos/secrets"
read -s -p "Password: " PASS && echo
echo "$PASS" | mkpasswd -m yescrypt -s > "$EXTRA/etc/nixos/secrets/augusto-password"

# 3. Install WITHOUT auto-reboot
nixos-anywhere --flake ~/nixos#laptop \
  --target-host root@<target-ip> \
  --extra-files "$EXTRA" \
  --chown /home/augusto 1000:100 \
  --phases kexec,disko,install

# 4. Run post-install via nixos-enter
ssh root@<target-ip>
nixos-enter --root /mnt -- fish /etc/post-install.fish --tpm --fido --sops --git-init

# 5. Reboot
reboot
```

The `--extra-files` flag copies the repo to the target. Use `--git-init` in the
post-install script to restore git history from the remote.

### Option B: Local install from the custom ISO

```bash
# 1. Boot the custom ISO

# 2. Install (formats disk, copies embedded repo, runs nixos-install)
install-local laptop

# 3. Run post-install for TPM/FIDO2 enrollment
sudo nixos-enter --root /mnt -- fish /etc/post-install.fish --tpm --fido --sops

# 4. Reboot
reboot
```

### Post-install flags

```
post-install.fish [FLAGS]

  --tpm          Enroll TPM2 for LUKS auto-unlock
  --fido         Enroll FIDO2 key(s) for LUKS unlock
  --fingerprint  Show fingerprint enrollment instructions
  --sops         Generate age key and configure sops-nix
  --dotfiles     Clone dotfiles repo to ~/nixos
  --media        Clone media repo to ~/media
  --git-init     Initialize git in ~/nixos (for --extra-files installs)
```

## Updating

```bash
# Full system rebuild
sudo nixos-rebuild switch --flake ~/nixos#laptop

# All flake inputs
nix flake update

# Neovim plugins only
update-neovim-plugins

# Firefox/Thunderbird extensions
update-firefox
update-thunderbird

# Regenerate flake.nix after changing module inputs
nix run .#write-flake
```

## Post Installation

### Fingerprint Enrollment

```fish
fprintd-enroll
fprintd-enroll -f right-index-finger
fprintd-enroll -f right-middle-finger
```

### Secrets Management

Secrets are managed using [sops-nix](https://github.com/Mic92/sops-nix) with age + GPG (YubiKey).

#### First-time setup on a new machine

```fish
nix-shell -p age sops yq-go --run "fish ~/nixos/modules/security/secrets/sops-setup.fish"
```

#### Adding new secrets

```fish
sops ~/nixos/modules/security/secrets/env.yaml
```

Add the secret key to `modules/security/secrets/secrets.nix` and the environment variable to the template.

### FirefoxPWA (Progressive Web Apps)

#### Creating a profile

```fish
firefoxpwa profile create --name "WhatsApp"
```

#### Installing a PWA

```fish
firefoxpwa site install https://web.whatsapp.com/data/manifest.json \
  --profile <PROFILE_ID> \
  --name "WhatsApp" \
  --icon-url "https://pngimg.com/uploads/whatsapp/whatsapp_PNG95154.png" \
  --document-url "https://web.whatsapp.com/" \
  --categories social
```

#### Hiding the browser toolbar

1. Launch the PWA once: `firefoxpwa site launch <SITE_ID>`
2. Enable custom stylesheets:

```fish
printf 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);\nuser_pref("media.hardwaremediakeys.enabled", false);\nuser_pref("firefoxpwa.openOutOfScopeInDefaultBrowser", true);\nuser_pref("pdfjs.disabled", true);\n' > \
  ~/.local/share/firefoxpwa/profiles/<PROFILE_ID>/user.js
```

3. Create userChrome.css:

```fish
echo '#nav-bar { display: none !important; }
#TabsToolbar { display: none !important; }' > \
  ~/.local/share/firefoxpwa/profiles/<PROFILE_ID>/chrome/userChrome.css
```

#### Auto-launching on login

Add to the `exec-once` section in `modules/desktop/hyprland.nix`:

```nix
"uwsm app -- firefoxpwa site launch <SITE_ID>"
```
