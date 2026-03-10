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

2. Add the new secret key to `home/secrets.nix`
3. Add the environment variable to the template in `home/secrets.nix`
4. Rebuild

### FirefoxPWA (Progressive Web Apps)

Web apps can be installed as standalone PWAs using [FirefoxPWA](https://github.com/nicegware/nicegware-nicegpwa). The CLI tool and browser connector are already installed.

#### Creating a profile

Each PWA should have its own profile to isolate cookies and data:

```fish
firefoxpwa profile create --name "WhatsApp"
```

Note the profile ID printed (e.g., `01KKC8KEY5WQTRM1P0WHT946CX`).

#### Installing a PWA site

```fish
firefoxpwa site install https://web.whatsapp.com/data/manifest.json \
  --profile 01KKC8KEY5WQTRM1P0WHT946CX \
  --name "WhatsApp" \
  --icon-url "https://pngimg.com/uploads/whatsapp/whatsapp_PNG95154.png" \
  --document-url "https://web.whatsapp.com/" \
  --categories social
```

Note the site ID printed (e.g., `01KKC8KPKEX5XZPBBK02D5ZM67`).

#### Listing profiles and sites

```fish
firefoxpwa profile list
```

#### Hiding the browser toolbar

By default, PWAs show a Firefox toolbar with navigation and settings buttons. To hide it:

1. Launch the PWA once to initialize its profile directory:

   ```fish
   firefoxpwa site launch <SITE_ID>
   ```

2. Enable custom stylesheets and optionally disable MPRIS (prevents the PWA from registering as a media player, stealing media controls from actual music apps). Create a `user.js` file in the profile directory:

   ```fish
   printf 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);\nuser_pref("media.hardwaremediakeys.enabled", false);\n' > \
     ~/.local/share/firefoxpwa/profiles/<PROFILE_ID>/user.js
   ```

   Alternatively go to `about:config` while inside the PWA application and change those settings manually.

3. Create the `userChrome.css` file:

   ```fish
   echo '#nav-bar { display: none !important; }
   #TabsToolbar { display: none !important; }' > \
     ~/.local/share/firefoxpwa/profiles/<PROFILE_ID>/chrome/userChrome.css
   ```

4. Restart the PWA.

#### Auto-launching on login

Add to the `exec-once` section in `home/hyprland.nix`:

```nix
"uwsm app -- firefoxpwa site launch <SITE_ID>"
```
