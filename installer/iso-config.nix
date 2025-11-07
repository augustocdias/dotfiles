# iso-config.nix - Configuration for the installer ISO
{
  pkgs,
  lib,
  ...
}: {
  # Enable experimental features for nix commands
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "90%";

  # Enable networking tools
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;

  # Enable SSH in the installer
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # Auto-login as nixos user and run installer
  services.getty.autologinUser = "nixos";

  # Create nixos user with auto-run wrapper
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialHashedPassword = lib.mkForce null;
    password = lib.mkForce "nixos";
  };

  # Set root password for the installer
  users.users.root = {
    initialHashedPassword = lib.mkForce null;
    password = lib.mkForce "nixos";
  };

  # Create auto-run wrapper that launches installer on first login
  environment.etc."auto-install-wrapper.sh" = {
    text = ''
      #!/usr/bin/env bash

      # Check if this is the first run (no marker file)
      if [ ! -f /tmp/.installer-ran ]; then
        # Mark that we've run
        touch /tmp/.installer-ran

        # Run the installer
        sudo fish /etc/install-script.fish

        # After installer exits (completed or cancelled), show message
        echo ""
        echo "Installer finished. You now have a shell."
        echo "Type 'install-system' to run the installer again if needed."
        echo ""
      fi

      # Drop to bash shell
      exec bash
    '';
    mode = "0755";
  };

  # Make nixos user use the auto-run wrapper on login
  programs.bash.loginShellInit = ''
    # Welcome message
    clear
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║  NixOS Interactive Installer with Hyprland ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""

    # Auto-run installer wrapper for nixos user
    if [ "$(whoami)" = "nixos" ] && [ -z "$INSTALLER_WRAPPER_RAN" ]; then
      export INSTALLER_WRAPPER_RAN=1
      exec /etc/auto-install-wrapper.sh
    fi
  '';

  # Essential packages in the installer
  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    wget
    curl
    htop
    tree
    parted
    gptfdisk
    cryptsetup
    tpm2-tools # For TPM2 LUKS enrollment
    libfido2 # For FIDO2 LUKS enrollment
    mkpasswd
    fish
    util-linux
    jq
    networkmanager
    nixos-install-tools
  ];

  # Better console font
  console = {
    font = "ter-v22n";
    packages = [pkgs.terminus_font];
  };

  # Interactive installation script
  environment.etc."install-script.fish" = {
    mode = "0755";
    text = builtins.readFile ./install-script.fish;
  };

  # Partition script
  environment.etc."partition-disk.fish" = {
    mode = "0755";
    text = builtins.readFile ./partition-disk.fish;
  };

  # Create convenient command alias
  environment.shellAliases = {
    install-system = "sudo fish /etc/install-script.fish";
  };
}
