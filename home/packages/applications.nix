{pkgs, ...}: {
  home.packages = with pkgs; [
    cider-2

    kitty

    zed-editor

    mpv

    imv

    peazip

    drawio

    libnotify
  ];
}
