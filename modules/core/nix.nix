{den, ...}: {
  den.aspects.nix = {
    nixos = {pkgs, ...}: {
      nixpkgs.config.allowUnfree = true;

      nix = {
        settings.experimental-features = ["nix-command" "flakes"];
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
