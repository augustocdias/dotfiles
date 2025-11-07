# Locale and timezone configuration
{...}: {
  # Timezone - Berlin, Germany
  time.timeZone = "Europe/Berlin";

  # Locale - English with German regional settings
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
  };

  # Keyboard layout - EurKEY (US-based with European characters)
  services.xserver.xkb.layout = "eu";
  console.keyMap = "us";
}
