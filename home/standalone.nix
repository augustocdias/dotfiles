{...}: let
  username = "augusto";
  homeDirectory = "/home/${username}";
  modules = import ./modules.nix;
in {
  imports = modules;
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
