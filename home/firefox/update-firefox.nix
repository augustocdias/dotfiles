# NOTE: only slug and name are mandatory to fill in the json. the other fields will be populated by this script
{pkgs, ...}: let
  update-firefox = pkgs.writeScriptBin "update-firefox" (builtins.readFile ./update-extensions.fish);
in {
  home.packages = [update-firefox];
}
