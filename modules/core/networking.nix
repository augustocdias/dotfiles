{...}: {
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  hardware.bluetooth.enable = true;

  programs.kdeconnect.enable = true;
}
