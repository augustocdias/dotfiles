# CLI tools and utilities
{pkgs, ...}: {
  home.packages = with pkgs; [
    # File explorers
    eza
    fd
    ripgrep
    fzf
    starship

    # Text processing
    bat
    delta
    moreutils
    lynx

    # System tools
    zoxide

    # Secrets management
    age
    sops

    # Calendar
    gcalcli

    # Media tools
    ffmpeg
    imagemagick
    exiftool
    poppler-utils
    tesseract
  ];
}
