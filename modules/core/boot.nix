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

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };

  # Blacklist the ACPI AC adapter module - it reports online=1 permanently
  # on work laptop, preventing UPower from detecting battery state.
  # Actual charging is handled by the UCSI subsystem.
  boot.blacklistedKernelModules = ["ac"];

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
