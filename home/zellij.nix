# Zellij terminal multiplexer configuration
{...}: {
  programs.zellij = {
    enable = true;
  };

  # Copy the KDL configuration file (516 lines)
  xdg.configFile."zellij/config.kdl".source = ./configs/zellij/config.kdl;

  # Copy all layout files
  xdg.configFile."zellij/layouts" = {
    source = ./configs/zellij/layouts;
    recursive = true;
  };
}
