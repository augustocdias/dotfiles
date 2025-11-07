# grub-config.nix - GRUB bootloader configuration with Catppuccin theme
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Catppuccin GRUB theme from flake input
  catppuccin-grub-theme = pkgs.stdenv.mkDerivation {
    pname = "catppuccin-grub-theme";
    version = "1.0.0";

    src = inputs.catppuccin-grub;

    installPhase = ''
      mkdir -p $out
      cp -r src/catppuccin-mocha-grub-theme/* $out/
    '';
  };
in {
  # Enable GRUB bootloader
  boot.loader = {
    # Disable systemd-boot
    systemd-boot.enable = lib.mkForce false;

    # Enable GRUB
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;

      # Catppuccin Mocha theme
      theme = catppuccin-grub-theme;
    };

    efi.canTouchEfiVariables = true;
  };
}
