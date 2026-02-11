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

    # System monitoring
    htop
    btop

    # File management
    tree
    p7zip

    # System tools
    zoxide

    # Secrets management
    age
    sops
    openssl

    # Yubikey tools
    yubikey-manager
    yubikey-personalization
    yubico-piv-tool

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
