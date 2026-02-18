# Shared home-manager module imports
[
  # Core configurations
  ./dank.nix
  ./hyprland.nix
  ./gpg.nix
  ./xdg.nix

  # Package collections
  ./packages/development.nix
  ./packages/cli-tools.nix
  ./packages/applications.nix
  ./packages/hyprland-tools.nix
  ./packages/fonts.nix

  # Tool configurations
  ./stylua.nix
  ./yamllint.nix
  ./neovide.nix
  ./bat.nix
  ./opencode.nix
  ./vicinae/vicinae.nix
  ./vicinae/update-vicinae.nix
  ./secrets.nix

  # Update scripts
  ./scripts/update-system.nix

  # Development tools
  ./git.nix

  # Terminal & File Manager
  ./kitty.nix
  ./yazi.nix

  # Shell Environment
  ./fish.nix
  ./starship.nix

  # Multiplexer
  ./zellij.nix

  # Neovim
  ./neovim/neovim.nix
  ./neovim/update-nvim.nix

  # Firefox
  ./firefox/firefox.nix
  ./firefox/update-firefox.nix

  # Work
  ./work.nix

  # Thunderbird
  ./thunderbird/thunderbird.nix
  ./thunderbird/update-thunderbird.nix
]
