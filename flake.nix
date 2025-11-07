{
  description = "Custom NixOS installer/system with Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland";

    hyprshutdown = {
      url = "github:hyprwm/hyprshutdown";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin-grub = {
      url = "github:catppuccin/grub/0a37ab19f654e77129b409fed371891c01ffd0b9";
      flake = false;
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugins = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sqlit = {
      url = "github:Maxteabag/sqlit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: {
    packages.aarch64-linux.installer =
      self.nixosConfigurations.installer.config.system.build.isoImage;
    # packages.x86_64.installer =
    #   self.nixosConfigurations.installer.config.system.build.isoImage;
    # ISO Image configuration
    nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      # system = "x86_64-linux";
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

        # Make ISO build faster
        {isoImage.squashfsCompression = "lz4";}

        # Our custom installer configuration
        ./installer/iso-config.nix

        # Include configs in the ISO as plain files (not evaluated)
        {
          environment.etc."nixos-installer/flake.nix".text = builtins.readFile ./flake.nix;
          environment.etc."nixos-installer/configuration.nix".text = builtins.readFile ./modules/configuration.nix;
          environment.etc."nixos-installer/grub-config.nix".text = builtins.readFile ./modules/grub-config.nix;
          environment.etc."nixos-installer/install-script.fish" = {
            mode = "0755";
            text = builtins.readFile ./installer/install-script.fish;
          };
          environment.etc."nixos-installer/partition-disk.fish" = {
            mode = "0755";
            text = builtins.readFile ./installer/partition-disk.fish;
          };
        }
      ];
    };

    # The target system configuration (what gets installed)
    nixosConfigurations.augusto = nixpkgs.lib.nixosSystem {
      # system = "x86_64-linux";
      system = "aarch64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        inputs.hyprland.nixosModules.default
        inputs.dms.nixosModules.greeter
        inputs.sops-nix.nixosModules.sops
        ./hardware-configuration.nix
        ./modules/configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            inputs.neovim-nightly-overlay.overlays.default
            # Overlay to add psycopg2 to sqlit
            (final: prev: {
              sqlit-with-postgres = let
                sqlitPkg = inputs.sqlit.packages.${prev.stdenv.hostPlatform.system}.default;
              in
                prev.symlinkJoin {
                  name = "sqlit-with-postgres";
                  paths = [sqlitPkg];
                  buildInputs = [prev.makeWrapper];
                  postBuild = ''
                    wrapProgram $out/bin/sqlit \
                      --prefix PYTHONPATH : "${prev.python3Packages.psycopg2}/${prev.python3.sitePackages}"
                  '';
                };
            })
          ];
        }
        {
          imports = [
            ./home
          ];
        }
      ];
    };
  };
}
