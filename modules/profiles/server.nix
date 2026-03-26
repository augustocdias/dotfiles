{den, ...}: {
  den.aspects.server = {
    includes = with den.aspects; [
      nix
      locale
      users
      disko
      security
      secrets
      networking
      podman
      git
      fish
      starship
      neovim
      cli-tools
      development-packages
    ];
  };
}
