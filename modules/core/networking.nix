{...}: {
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        ClassicBondedOnly = false;
      };
    };
  };

  programs.kdeconnect.enable = true;
}
