{
  den,
  inputs,
  lib,
  ...
}: {
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  den.ctx.user.includes = [den._.mutual-provider];

  den.ctx.hm-host = {
    nixos.home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      sharedModules = lib.optionals (inputs ? sops-nix) [
        inputs.sops-nix.homeManagerModules.sops
      ];
    };
  };

  den.default = {
    nixos.system.stateVersion = "26.05";
    homeManager.home.stateVersion = "26.05";
    includes = [
      den._.define-user
      den._.primary-user
      (den._.user-shell "fish")
    ];
  };
}
