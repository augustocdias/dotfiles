{...}: {
  imports = [
    ../hardware-configuration.nix

    ./core/boot.nix
    ./core/networking.nix
    ./core/locale.nix
    ./core/hardware.nix
    ./core/hyprland.nix
    ./core/security.nix
    ./core/users.nix

    ./services/display-manager.nix
    ./services/docker.nix
    ./services/yubikey.nix
    ./services/work.nix
    ./services/input-devices.nix

    ./system-packages/essential.nix
    ./system-packages/development.nix
    ./system-packages/security.nix

    ./grub-config.nix
  ];

  system.stateVersion = "25.11";
}
