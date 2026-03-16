{pkgs, ...}: {
  home.packages = with pkgs; [
    brightnessctl
    playerctl
    wl-clipboard
    wl-clip-persist
    mpvpaper

    hyprland-qt-support
    hyprland-qtutils
    hyprpwcenter

    libsForQt5.qt5ct
    kdePackages.qt6ct
    adw-gtk3
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
