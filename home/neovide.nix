{pkgs, ...}: let
in {
  home.packages = with pkgs; [neovide];
  xdg.configFile."neovide/config.toml".source = ./configs/neovide/config.toml;
}
