# grub-config.nix - GRUB bootloader configuration with Catppuccin theme
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Catppuccin GRUB theme
  catppuccin-grub = pkgs.stdenv.mkDerivation {
    pname = "catppuccin-grub";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "grub";
      rev = "88bdaa02cffe76e80506e9a3b8ca7b1e5d653d1d";
      hash = "sha256-I/oOp/cFRO9pePRI4KbXPP7zW/SYKUNIPEhqaflL2ng=";
    };

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
      theme = catppuccin-grub;
    };

    efi.canTouchEfiVariables = true;
  };
}
