{pkgs, ...}: {
  boot.initrd = {
    systemd.enable = true;
    availableKernelModules = ["tpm_crb" "tpm_tis"];
  };

  boot.plymouth = {
    enable = true;
    theme = "catppuccin-mocha";
    themePackages = [
      (pkgs.catppuccin-plymouth.override {variant = "mocha";})
    ];
  };

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "suspend";
    lidSwitchDocked = "ignore";
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
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
