{pkgs, ...}: {
  boot.initrd.systemd.enable = true;

  boot.plymouth = {
    enable = true;
    theme = "catppuccin-mocha";
    themePackages = [
      (pkgs.catppuccin-plymouth.override {variant = "mocha";})
    ];
  };

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
