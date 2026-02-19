{pkgs, ...}: let
  update-thunderbird = pkgs.writeScriptBin "update-thunderbird" (builtins.readFile ./update-extensions.fish);
in {
  home.packages = [update-thunderbird];
}
