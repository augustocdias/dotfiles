{den, ...}: {
  den.aspects.development-system = {
    nixos = {pkgs, ...}: {
      # Allows dynamically linked executables (add more pkgs if needed by specific binaries)
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          libz
        ];
      };

      programs.dconf.enable = true;
    };
  };
}
