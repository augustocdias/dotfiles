# hyprland-config.nix - Hyprland window manager setup
{
  config,
  pkgs,
  silentSDDM,
  ...
}: let
  sddm-theme = silentSDDM.packages.${pkgs.system}.default.override {
    theme = "rei";
  };
in {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Required environment variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
    TERMINAL = "wezterm";
  };

  # Display manager - SDDM for nice login screen
  qt.enable = true;
  environment.systemPackages = with pkgs.kdePackages; [
    sddm-theme
    qtmultimedia
    qtsvg
    qtvirtualkeyboard
  ];
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = sddm-theme.pname;
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
    ];
    settings = {
      General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };

  services.xserver.enable = true;

  # Security for screen locking
  security.pam.services.hyprlock = {};

  # Polkit authentication agent (Qt-based)
  systemd.user.services.polkit-kde-agent = {
    description = "Polkit KDE Authentication Agent";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Enable dconf (required for some apps)
  programs.dconf.enable = true;
  programs.direnv.enable = true;
}
