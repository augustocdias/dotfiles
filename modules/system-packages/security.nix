# Security-related system packages (boot/encryption essentials only)
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Disk encryption (needed at boot)
    cryptsetup
    tpm2-tools
    libfido2

    # GPG (needed system-wide for pinentry)
    gnupg
    pinentry-bemenu
    pinentry-curses
    bemenu
  ];
}
