{
  pkgs,
  lib,
  ...
}: let
  isX86 = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
in {
  home.packages = with pkgs;
    [
      wireguard-tools

      teamviewer
    ]
    ++ lib.optionals isX86 [
      slack
      notion-app-enhanced
    ];
}
