{
  description = "Custom NixOS installer/system with Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland";

    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    awww.url = "git+https://codeberg.org/LGFae/awww";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin-grub = {
      url = "github:catppuccin/grub/0a37ab19f654e77129b409fed371891c01ffd0b9";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    hyprland,
    vicinae,
    awww,
    neovim-nightly-overlay,
    catppuccin-grub,
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
          environment.etc."nixos-installer/hyprland-config.nix".text = builtins.readFile ./modules/hyprland-config.nix;
          environment.etc."nixos-installer/packages.nix".text = builtins.readFile ./modules/packages.nix;
          environment.etc."nixos-installer/eurkey.nix".text = builtins.readFile ./modules/eurkey.nix;
          environment.etc."nixos-installer/grub-config.nix".text = builtins.readFile ./modules/grub-config.nix;
          environment.etc."nixos-installer/install-script.sh" = {
            mode = "0755";
            text = builtins.readFile ./installer/install-script.sh;
          };
          environment.etc."nixos-installer/partition-disk.sh" = {
            mode = "0755";
            text = builtins.readFile ./installer/partition-disk.sh;
          };
        }
      ];
    };

    # The target system configuration (what gets installed)
    nixosConfigurations.augusto = nixpkgs.lib.nixosSystem {
      # system = "x86_64-linux";
      system = "aarch64-linux";
      specialArgs = {inherit vicinae awww neovim-nightly-overlay catppuccin-grub;};
      modules = [
        hyprland.nixosModules.default

        ./hardware-configuration.nix
        ./modules/configuration.nix
      ];
    };
  };
}
