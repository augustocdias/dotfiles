# Work-related tools and applications
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Communication
    # slack

    # Productivity
    # notion-app-enhanced

    # VPN
    wireguard-tools

    # Remote access
    teamviewer
  ];
}
