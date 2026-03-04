{pkgs, ...}: let
in {
  home.packages = with pkgs; [
    wireguard-tools

    slack
    teamviewer
    jetbrains.datagrip
  ];
}
