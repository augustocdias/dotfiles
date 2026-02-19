# To update extensions: Run update-vicinae
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  config = builtins.fromJSON (builtins.readFile ./extensions.json);

  vicinaeExtPkgs = inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system};
  vicinaePackages =
    map (name: {
      inherit name;
      pkg = vicinaeExtPkgs.${name};
    })
    config.vicinae;

  shas = {
    "1password" = "sha256-I1STC8w316kV8It3Be35mwLvNSYPJqy1bG+XaIRMRpg=";
    chatgpt = "sha256-n9WdOWQEgMkEL5Rqs7z8C2qil/0fru1kXYngNfxFlm4=";
    github = "sha256-L5MvKy5+PM38JOIJnX8fQL/FcJIDPNP62bvirzTaza8=";
    jira = "sha256-+6IWQI6JsyPmLBDfBsSIFiF1u7f4aYvi8Fjxa+o4YN4=";
    notion = "sha256-ZVijHU6QVIFk/rRhUDwxNZUjG1hufk6v9E2knEWg6LY=";
  };

  mkRayCastExtension = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.mkRayCastExtension;

  raycastPackages =
    lib.mapAttrsToList (name: ext: {
      inherit name;
      pkg = mkRayCastExtension {
        inherit name;
        rev = ext.rev;
        sha256 = shas.${name};
      };
    })
    config.raycast;
in {
  inherit vicinaePackages raycastPackages;
}
