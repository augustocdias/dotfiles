{pkgs, ...}: {
  home.packages = with pkgs; [
    cider-2

    wasistlos

    kitty

    zed-editor

    mpv

    imv

    peazip

    drawio

    libnotify
  ];
}
