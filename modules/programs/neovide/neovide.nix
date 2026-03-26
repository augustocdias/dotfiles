{den, ...}: {
  den.aspects.neovide = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.neovide];
      xdg.configFile."neovide/config.toml".source = ./config.toml;
    };
  };
}
