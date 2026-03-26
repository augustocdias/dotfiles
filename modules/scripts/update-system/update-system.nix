{den, ...}: {
  den.aspects.update-system = {
    homeManager = {pkgs, ...}: let
      update-system = pkgs.writeScriptBin "update-system" (builtins.readFile ./update-system.fish);
    in {
      home.packages = [update-system];
    };
  };
}
