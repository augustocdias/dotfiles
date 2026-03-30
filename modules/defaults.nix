{
  den,
  inputs,
  lib,
  ...
}: {
  den.schema.user.classes = lib.mkDefault ["homeManager"];

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
    nixos = {pkgs, ...}: {
      nixpkgs.config.allowUnfree = true;

      nix = {
        settings = {
          experimental-features = ["nix-command" "flakes"];
          extra-substituters = [
            "https://hyprland.cachix.org"
            "https://nix-community.cachix.org"
          ];
          extra-trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
        optimise = {
          automatic = true;
          dates = ["weekly"];
        };
      };

      environment.systemPackages = with pkgs; [
        coreutils
        curl
        wget
        git
      ];

      system.stateVersion = "26.05";
    };

    homeManager.home.stateVersion = "26.05";

    includes = [
      den._.define-user
      den._.primary-user
      (den._.user-shell "fish")
    ];
  };
}
