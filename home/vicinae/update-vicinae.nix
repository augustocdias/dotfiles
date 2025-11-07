# Vicinae extension update command
{pkgs, ...}: let
  update-vicinae = pkgs.writeScriptBin "update-vicinae" (builtins.readFile ./update-extensions.fish);
in {
  home.packages = [update-vicinae];
}
