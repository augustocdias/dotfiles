{den, ...}: {
  den.aspects.yamllint = {
    homeManager = _: {
      xdg.configFile."yamllint/config".source = ./config;
    };
  };
}
