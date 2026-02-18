# GUI applications
{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Communication
    wasistlos

    # Terminal emulators
    kitty

    # Development GUI
    zed-editor

    # Media players
    mpv

    # Image viewer
    imv

    # Archive manager
    peazip

    # Graphics & Diagrams
    drawio

    # Utilities
    libnotify

    # Custom packages
    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
