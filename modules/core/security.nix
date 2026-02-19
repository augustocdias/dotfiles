{
  pkgs,
  lib,
  ...
}: let
  u2fKeysFile = ./u2f_keys;
  u2fKeysExist = builtins.pathExists u2fKeysFile;

  pamAuthConfig = {
    u2fAuth = true;
    fprintAuth = true;
    rules.auth = {
      fprintd = {
        control = "sufficient";
        order = 10800;
      };
      u2f = {
        control = "sufficient";
        order = 10900;
      };
    };
  };
in {
  security.polkit.enable = true;

  services.dbus.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  security.pam.u2f = lib.mkIf u2fKeysExist {
    enable = true;
    settings = {
      cue = true; # Show "Please touch the device" prompt
      authfile = "/etc/u2f_keys"; # System-wide key file
    };
  };

  security.pam.services.greetd = lib.mkIf u2fKeysExist pamAuthConfig;
  security.pam.services.sudo = lib.mkIf u2fKeysExist pamAuthConfig;
  security.pam.services.polkit-1 = lib.mkIf u2fKeysExist pamAuthConfig;
  security.pam.services.login = lib.mkIf u2fKeysExist pamAuthConfig;

  environment.etc."u2f_keys" = lib.mkIf u2fKeysExist {
    source = u2fKeysFile;
    mode = "0644";
  };

  environment.systemPackages = [pkgs.pam_u2f];
}
