{den, ...}: {
  den.aspects.locale = {
    nixos = {pkgs, ...}: {
      time.timeZone = "Europe/Berlin";

      i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [
          "en_US.UTF-8/UTF-8"
          "de_DE.UTF-8/UTF-8"
          "pt_BR.UTF-8/UTF-8"
        ];
        extraLocaleSettings = {
          LC_TIME = "de_DE.UTF-8";
          LC_MONETARY = "de_DE.UTF-8";
          LC_PAPER = "de_DE.UTF-8";
          LC_MEASUREMENT = "de_DE.UTF-8";
        };
      };

      environment.systemPackages = with pkgs; [
        hunspell
        hunspellDicts.en_US
        hunspellDicts.de_DE
        hunspellDicts.pt_BR
      ];

      services.xserver.xkb.layout = "eu";
      console.keyMap = "us";
    };
  };
}
