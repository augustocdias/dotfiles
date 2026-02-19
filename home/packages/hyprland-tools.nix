{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    blueberry
    brightnessctl
    playerctl
    wl-clipboard
    wl-clip-persist
    mpvpaper

    hyprland-qt-support
    hyprland-qtutils
    hyprpwcenter
    inputs.hyprshutdown.packages.${pkgs.stdenv.hostPlatform.system}.default

    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];

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
