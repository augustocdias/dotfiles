# configuration.nix - Main system configuration
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../hardware-configuration.nix
    ./hyprland-config.nix
    ./packages.nix
    ./grub-config.nix
  ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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

  # Keyboard layout - US as base (will add EURkey post-install)
  services.xserver.xkb = {
    layout = "us";
    options = "";
  };

  console.keyMap = "us";

  # Audio with PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Graphics
  hardware.opengl = {
    enable = true;
  };

  # Use systemd in initrd for LUKS TPM2/FIDO2 unlock
  boot.initrd.systemd.enable = true;

  # User Management
  users.mutableUsers = false;
  users.users.augusto = {
    isNormalUser = true;
    description = "Augusto";
    extraGroups = ["wheel" "networkmanager" "docker"];
    shell = pkgs.fish;
    hashedPasswordFile = "/etc/nixos/secrets/augusto-password";
  };

  # Enable fish system-wide
  programs.fish.enable = true;

  # GPG Agent for Yubikey
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses; # Terminal-based pinentry
  };

  # Smart card support for Yubikey
  services.pcscd.enable = true;

  # Yubikey udev rules
  services.udev.packages = [pkgs.yubikey-personalization];

  # System-wide shell aliases
  environment.shellAliases = {
    ls = "eza --icons --group-directories-first";
    ll = "eza -l --icons --group-directories-first";
    la = "eza -la --icons --group-directories-first";
    lt = "eza --tree --icons --group-directories-first";
    grep = "rg";
    cat = "bat";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Polkit for privilege escalation
  security.polkit.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
  };

  system.stateVersion = "25.05";
}
