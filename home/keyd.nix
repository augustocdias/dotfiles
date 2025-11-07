# Keyd application-specific configuration
# Disables macOS-style shortcuts for terminals so they can handle them natively
{pkgs, ...}: {
  # App-specific keyd config
  xdg.configFile."keyd/app.conf".text = ''
    [kitty]
    # Let kitty handle Super+key directly
    meta.c = M-c
    meta.v = M-v
    meta.t = M-t
    meta.w = M-w
    meta.n = M-n
  '';

  # Run keyd-application-mapper daemon
  systemd.user.services.keyd-application-mapper = {
    Unit = {
      Description = "Keyd application mapper for app-specific remapping";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.keyd}/bin/keyd-application-mapper";
      Environment = "PATH=${pkgs.keyd}/bin";
      Restart = "on-failure";
      RestartSec = 3;
      Type = "simple";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
