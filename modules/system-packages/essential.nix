{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    wget
    git
  ];
}
