# Hyprland and Wayland tools
{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # Hyprland utilities
    blueberry
    brightnessctl
    # clipse # terminal clipboard manager
    playerctl
    wl-clipboard
    wl-clip-persist
    mpvpaper

    # Hyprland ecosystem
    hyprpolkitagent
    hyprland-qt-support
    hyprland-qtutils
    hyprpwcenter
    inputs.hyprshutdown.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Qt/Wayland tools
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];

  # Clipboard persistence daemon for Wayland
  # Keeps clipboard contents after source application closes
  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "Persistent clipboard for Wayland";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
