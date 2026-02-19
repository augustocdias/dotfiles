{
  pkgs,
  lib,
  inputs,
  ...
}: let
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
  boot.loader = {
    systemd-boot.enable = lib.mkForce false;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;

      theme = catppuccin-grub-theme;
    };

    efi.canTouchEfiVariables = true;
  };
}
