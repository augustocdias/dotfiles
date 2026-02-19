{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cryptsetup
    tpm2-tools
    libfido2

    gnupg
    pinentry-bemenu
    pinentry-curses
    bemenu
  ];
}
