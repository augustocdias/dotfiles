{den, ...}: {
  den.aspects.input-devices = {
    nixos = {
      services.fprintd.enable = true;

      # The Synaptics USB sensor disconnects during sleep and fprintd gets stuck
      # with a stale "Device already claimed" state, refusing new auth requests.
      systemd.services.fprintd-resume = {
        description = "Restart fprintd after resume";
        after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
        wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/systemd/bin/systemctl restart fprintd.service";
        };
      };

      services.libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          tapping = true;
          clickMethod = "clickfinger";
          accelSpeed = "1.0";
          accelProfile = "flat";
          disableWhileTyping = true;
        };
      };
    };
  };
}
