# Essential system utilities
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Core utilities
    coreutils
    curl
    wget
    git

    # System monitoring
    htop
    btop

    # File management
    tree
    p7zip
  ];
}
