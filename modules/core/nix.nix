{den, ...}: {
  den.aspects.nix = {
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
    };
  };
}
