# refind-config.nix - rEFInd bootloader configuration with Catppuccin theme
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable rEFInd bootloader
  boot.loader = {
    # Disable systemd-boot
    systemd-boot.enable = lib.mkForce false;

    # Enable rEFInd
    refind = {
      enable = true;

      # Extra configuration to include the Catppuccin mocha theme
      extraConfig = ''
        # Include Catppuccin Mocha theme
        include themes/catppuccin/mocha.conf
      '';
    };

    efi.canTouchEfiVariables = true;
  };

  # Copy theme files to /boot/EFI/refind/themes/catppuccin
  system.activationScripts.refindTheme = lib.stringAfter ["var"] ''
    # Create themes directory
    mkdir -p /boot/EFI/refind/themes/catppuccin

    # Copy theme files
    ${pkgs.rsync}/bin/rsync -av --delete \
      ${./refind-theme}/ \
      /boot/EFI/refind/themes/catppuccin/
  '';
}
