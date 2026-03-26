{den, ...}: {
  den.aspects.teamviewer = {
    nixos = {lib, ...}: {
      services.teamviewer.enable = true;
      # Don't auto-start at boot; use: sudo systemctl start teamviewerd
      systemd.services.teamviewerd.wantedBy = lib.mkForce [];
    };
  };
}
