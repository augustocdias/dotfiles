{den, ...}: {
  den.hosts.x86_64-linux.laptop = {
    hostName = "nixos";
    aspect = "laptop";
    users.augusto = {};
  };

  # den.hosts.aarch64-linux.raspi = {
  #   hostName = "raspi";
  #   aspect = "raspi";
  #   users.augusto = {};
  # };
}
