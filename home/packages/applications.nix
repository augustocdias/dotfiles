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
    vlc
    mpv
    # cider

    # Graphics & Diagrams
    drawio

    # Utilities
    libnotify

    # Custom packages
    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
