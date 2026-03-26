{den, ...}: {
  den.aspects.zellij = {
    homeManager = _: {
      programs.zellij.enable = true;
      xdg.configFile."zellij/config.kdl".source = ./config.kdl;
      xdg.configFile."zellij/layouts" = {
        source = ./layouts;
        recursive = true;
      };
    };
  };
}
