{pkgs, ...}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = [pkgs.podman-compose];
  environment.variables.PODMAN_COMPOSE_WARNING_LOGS = "false";
}
