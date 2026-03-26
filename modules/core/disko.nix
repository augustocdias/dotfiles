{
  den,
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.disko = {
    url = lib.mkDefault "github:nix-community/disko/latest";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.disko = {
    nixos = {
      imports = lib.optionals (inputs ? disko) [inputs.disko.nixosModules.disko];
    };
  };
}
