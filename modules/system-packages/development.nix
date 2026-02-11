# System-wide development tools (containers only - need system-level)
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];
}
