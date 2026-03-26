{den, ...}: {
  den.aspects.mpv = {
    homeManager = _: {
      programs.mpv = {
        enable = true;
        config = {
          hwdec = "auto-safe";
          vo = "gpu";
          profile = "gpu-hq";
          gpu-context = "wayland";
        };
      };
    };
  };
}
