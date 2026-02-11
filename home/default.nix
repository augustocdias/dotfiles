# Home-manager NixOS module configuration
{inputs, ...}: let
  username = "augusto";
  homeDirectory = "/home/${username}";
  modules = import ./modules.nix;
in {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {inherit inputs;};
  home-manager.sharedModules = [inputs.sops-nix.homeManagerModules.sops];
  home-manager.users.${username} = {
    imports = modules;
    home.username = username;
    home.homeDirectory = homeDirectory;
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };
}
