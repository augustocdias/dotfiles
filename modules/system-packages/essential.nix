# Essential system utilities (minimal - boot/recovery only)
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    wget
    git
  ];
}
