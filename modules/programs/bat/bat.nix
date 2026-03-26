{den, ...}: {
  den.aspects.bat = {
    homeManager = {pkgs, ...}: {
      programs.bat = {
        enable = true;
        config = {
          theme = "Catppuccin Mocha";
          pager = "less -FR";
          style = "numbers,changes,header";
        };
      };

      xdg.configFile."bat/themes" = {
        source = ./themes;
        recursive = true;
        onChange = ''
          ${pkgs.bat}/bin/bat cache --build
        '';
      };
    };
  };
}
