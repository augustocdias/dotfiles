{
  pkgs,
  lib,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "90%";

  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  services.getty.autologinUser = "nixos";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialHashedPassword = lib.mkForce null;
    password = lib.mkForce "nixos";
  };

  users.users.root = {
    initialHashedPassword = lib.mkForce null;
    password = lib.mkForce "nixos";
  };

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
    tpm2-tools
    libfido2
    mkpasswd
    fish
    util-linux
    jq
    networkmanager
    nixos-install-tools
  ];

  console = {
    font = "ter-v22n";
    packages = [pkgs.terminus_font];
  };

  environment.etc."install-script.fish" = {
    mode = "0755";
    text = builtins.readFile ./install-script.fish;
  };

  environment.etc."partition-disk.fish" = {
    mode = "0755";
    text = builtins.readFile ./partition-disk.fish;
  };

  environment.shellAliases = {
    install-system = "sudo fish /etc/install-script.fish";
  };
}
