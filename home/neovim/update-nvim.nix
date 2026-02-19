{pkgs, ...}: let
  update-nvim = pkgs.writeScriptBin "update-nvim" (builtins.readFile ./update-plugins.fish);
in {
  home.packages = [update-nvim];
}
