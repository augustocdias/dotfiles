# Security configuration
{
  pkgs,
  lib,
  ...
}: let
  u2fKeysFile = ./u2f_keys;
  u2fKeysExist = builtins.pathExists u2fKeysFile;
in {
  security.polkit.enable = true;

  services.dbus.enable = true;

  # 1Password
  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # FIDO2/U2F security key authentication (only if keys file exists)
  security.pam.u2f = lib.mkIf u2fKeysExist {
    enable = true;
    settings = {
      cue = true; # Show "Please touch the device" prompt
      authfile = "/etc/u2f_keys"; # System-wide key file
    };
  };

  # Greetd: passwordless with security key
  security.pam.services.greetd = lib.mkIf u2fKeysExist {
    u2fAuth = true;
    rules.auth.u2f.control = "sufficient";
  };

  # Sudo: security key OR password
  security.pam.services.sudo = lib.mkIf u2fKeysExist {
    u2fAuth = true;
    rules.auth.u2f.control = "sufficient";
  };

  # Deploy u2f_keys from dotfiles to /etc
  environment.etc."u2f_keys" = lib.mkIf u2fKeysExist {
    source = u2fKeysFile;
    mode = "0644";
  };

  # Ensure pam_u2f is available
  environment.systemPackages = [pkgs.pam_u2f];
}
