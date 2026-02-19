{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    fd
    ripgrep
    fzf
    starship

    bat
    delta
    moreutils
    lynx

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

    gcalcli

    ffmpeg
    imagemagick
    exiftool
    poppler-utils
    tesseract
  ];
}
