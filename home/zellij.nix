{...}: {
  programs.zellij = {
    enable = true;
  };

  xdg.configFile."zellij/config.kdl".source = ./configs/zellij/config.kdl;

  xdg.configFile."zellij/layouts" = {
    source = ./configs/zellij/layouts;
    recursive = true;
  };
}
