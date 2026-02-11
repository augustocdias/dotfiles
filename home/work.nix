# Work-related tools and applications
{pkgs, lib, ...}: let
  isX86 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in {
  home.packages = with pkgs;
    [
      # VPN
      wireguard-tools

      # Remote access
      teamviewer
    ]
    ++ lib.optionals isX86 [
      # x86-only packages
      slack
      notion-app-enhanced
    ];
}
