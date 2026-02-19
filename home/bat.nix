{pkgs, ...}: let
in {
  programs.bat = {
    enable = true;

    config = {
      theme = "Catppuccin Mocha";

      pager = "less -FR";
      style = "numbers,changes,header";
    };
  };

  xdg.configFile."bat/themes" = {
    source = ./configs/bat/themes;
    recursive = true;
    onChange = ''
      ${pkgs.bat}/bin/bat cache --build
    '';
  };
}
