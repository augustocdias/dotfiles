{...}: {
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
  };

  services.xserver.xkb.layout = "eu";
  console.keyMap = "us";
}
