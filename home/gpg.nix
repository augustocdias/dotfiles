{pkgs, ...}: {
  programs.gpg = {
    enable = true;
    settings = {
      pinentry-mode = "loopback";
    };
    publicKeys = [
      {
        source = pkgs.fetchurl {
          url = "https://keys.openpgp.org/vks/v1/by-fingerprint/7D8396F74725A208D835CE3730E62A1E4F078650";
          hash = "sha256-v11agJZKThP3/rNN23vyTEwnOk8928JBDlER7Dub4Gc=";
        };
        trust = "ultimate";
      }
    ];
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentry.package = pkgs.pinentry-bemenu;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    extraConfig = ''
      allow-loopback-pinentry
      extra-socket /tmp/S.gpg-agent.extra
    '';
  };
}
