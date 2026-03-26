{den, ...}: {
  den.aspects.workstation = {
    includes = with den.aspects; [
      # core
      nix
      locale
      users
      development-system
      disko

      # security
      security
      secrets

      # desktop
      boot
      hyprland
      login-manager

      # hardware
      networking
      input-devices

      # services
      podman
      virtualization
      teamviewer
      lotion
      datagrip
      slack
      wireguard
      sqlit

      # programs
      neovim
      git
      fish
      kitty
      firefox
      thunderbird
      zellij
      starship
      bat
      yazi
      mpv
      skim
      neovide
      opencode
      udiskie
      stylua
      yamllint
      xdg
      gcalcli

      # packages
      cli-tools
      fonts
      development-packages
      applications

      # scripts
      update-system
    ];
  };
}
