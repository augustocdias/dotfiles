# Boot configuration
{pkgs, ...}: {
  # Use systemd in initrd for LUKS TPM2/FIDO2 unlock
  boot.initrd.systemd.enable = true;

  # Plymouth splash screen
  boot.plymouth = {
    enable = true;
    theme = "catppuccin-mocha";
    themePackages = [
      (pkgs.catppuccin-plymouth.override {variant = "mocha";})
    ];
  };

  # Silent boot - hide kernel messages
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "udev.log_level=3"
    "rd.systemd.show_status=auto"
  ];
}
