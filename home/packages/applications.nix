{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    cider

    wasistlos

    kitty

    zed-editor

    mpv

    imv

    peazip

    drawio

    libnotify

    inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
