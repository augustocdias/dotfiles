{pkgs, ...}: {
  home.packages = with pkgs; [
    cider-2

    wasistlos-no-mpris

    kitty

    zed-editor

    mpv

    imv

    peazip

    drawio

    libnotify
  ];
}
