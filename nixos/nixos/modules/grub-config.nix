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
      rev = "0a37ab19f654e77129b409fed371891c01ffd0b9";
      hash = "sha256-9jfMa42rZqK66J7w4rs+LEUtHjWdw94c/G6mbowHiJc=";
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
