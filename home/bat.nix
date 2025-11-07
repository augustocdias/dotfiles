# Bat - A cat clone with syntax highlighting
{pkgs, ...}: let
in {
  programs.bat = {
    enable = true;

    config = {
      # Use Catppuccin Mocha theme
      theme = "Catppuccin Mocha";

      # Other bat settings
      pager = "less -FR";
      style = "numbers,changes,header";
    };
  };

  # Install the Catppuccin themes
  xdg.configFile."bat/themes" = {
    source = ./configs/bat/themes;
    recursive = true;
    onChange = ''
      ${pkgs.bat}/bin/bat cache --build
    '';
  };
}
