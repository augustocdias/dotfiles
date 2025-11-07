# Keyd - key remapping daemon
# macOS-style shortcuts + oneshot modifiers + capslock as ctrl/esc
{...}: {
  # Add CAP_SETGID so keyd can switch to keyd group (NixOS bug workaround)
  # https://github.com/NixOS/nixpkgs/issues/290161
  users.groups.keyd = {};
  systemd.services.keyd.serviceConfig.CapabilityBoundingSet = ["CAP_SETGID"];

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      settings = {
        main = {
          # Capslock: hold = Ctrl, tap = Esc
          capslock = "overload(control, esc)";

          # Oneshot modifiers (tap then release, next key uses modifier)
          shift = "oneshot(shift)";
          rightshift = "oneshot(shift)";
          control = "oneshot(control)";
          rightcontrol = "oneshot(control)";
          leftalt = "oneshot(alt)";
          rightalt = "oneshot(altgr)";
        };

        # macOS-style shortcuts: Super+key → Ctrl+key
        meta = {
          c = "C-c";
          v = "C-v";
          x = "C-x";
          a = "C-a";
          z = "C-z";
          s = "C-s";
          w = "C-w";
          t = "C-t";
          n = "C-n";
          f = "C-f";
          p = "C-p";
          o = "C-o";
          r = "C-r";
          l = "C-l";
        };

        # Super+Shift combinations
        "meta+shift" = {
          z = "C-S-z";
        };
      };
    };
  };
}
