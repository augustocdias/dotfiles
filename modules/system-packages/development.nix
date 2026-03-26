{pkgs, ...}: {
  # allows dynamically linked executables. (add more pkgs if needed by specific binaries)
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        libz
      ];
    };
    dconf.enable = true;
  };
}
