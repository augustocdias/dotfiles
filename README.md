# Personal Settings and Tools (NixOS + Home-Manager)

## NixOS Installer ISO

To build the iso, run:

```bash
docker run --rm -it -v $(pwd):/workspace -w /workspace nixos/nix sh -c "nix build --extra-experimental-features 'nix-command flakes' .#nixosConfigurations.installer.config.system.build.isoImage && cp result/iso/*.iso ."
```

The installer will guide through the process and at the end the machine should be ready to roll.

## Post Installation

Most apps come already pre-configured from home-manager. All plugins and configurations are pre-installed. Some features require manual setup after the first boot as described below.

### Fingerprint Enrollment

The fingerprint sensor is enabled but fingerprints must be enrolled on a running system as it requires the `fprintd` daemon. Run:

```fish
fprintd-enroll
```

Follow the prompts to scan your finger. To enroll multiple fingers:

```fish
fprintd-enroll -f right-index-finger
fprintd-enroll -f right-middle-finger
```

Once enrolled, fingerprint authentication will work for login and sudo.

### Secrets Management

Secrets are managed using [sops-nix](https://github.com/Mic92/sops-nix) with a hybrid age + GPG setup:

- **Age keys**: Per-machine keys for automatic decryption at login
- **GPG (YubiKey)**: Master key for bootstrapping new machines

#### First-time setup on a new machine

1. Plug in the YubiKey
2. Run the setup script:

   ```fish
   nix-shell -p age sops yq-go --run "fish ~/nixos/home/secrets/sops-setup.fish"
   ```

3. The script will:
   - Generate a new age key for this machine
   - Update `.sops.yaml` with the new key
   - Re-encrypt secrets

#### Adding new secrets

1. Edit the secrets file:

   ```fish
   sops ~/.dotfiles/home/secrets/env.yaml
   ```

1. Add the new secret key to `home/secrets.nix`
1. Add the environment variable to the template in `home/secrets.nix`
1. Rebuild
