# Main system configuration
{...}: {
  imports = [
    # Hardware
    ../hardware-configuration.nix

    # Core system modules
    ./core/boot.nix
    ./core/networking.nix
    ./core/locale.nix
    ./core/hardware.nix
    ./core/hyprland.nix
    ./core/security.nix
    ./core/users.nix

    # Services
    ./services/display-manager.nix
    ./services/docker.nix
    ./services/yubikey.nix
    ./services/work.nix

    # System packages
    ./system-packages/essential.nix
    ./system-packages/development.nix
    ./system-packages/security.nix

    # Other configurations
    ./grub-config.nix
  ];

  system.stateVersion = "25.11";
}
