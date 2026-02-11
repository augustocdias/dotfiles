# Network configuration
{...}: {
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.resolved.enable = true;

  # Disable wait-online (causes 60s boot delay via docker → network-online.target)
  systemd.services.NetworkManager-wait-online.enable = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
