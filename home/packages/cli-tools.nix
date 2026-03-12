{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    fd
    ripgrep
    starship

    bat
    delta
    moreutils

    htop
    btop

    tree
    p7zip

    zoxide

    age
    sops
    openssl

    yubikey-manager
    yubikey-personalization
    yubico-piv-tool

    ffmpeg
    imagemagick
    exiftool
    poppler-utils
    tesseract
    dragon-drop
  ];
}
