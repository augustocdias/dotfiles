# Standalone home-manager configuration
# Used with: home-manager switch --flake .#augusto
{...}: let
  username = "augusto";
  homeDirectory = "/home/${username}";
  modules = import ./modules.nix;
in {
  imports = modules;
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
