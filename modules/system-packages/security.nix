# Security-related system packages
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # GPG and encryption
    gnupg
    pinentry-bemenu
    pinentry-curses
    bemenu
    openssl

    # Yubikey tools
    yubikey-manager
    yubikey-personalization
    yubico-piv-tool

    # Disk encryption
    cryptsetup
    tpm2-tools
    libfido2
  ];
}
