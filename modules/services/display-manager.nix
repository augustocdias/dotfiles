{
  pkgs,
  config,
  ...
}: {
  qt.enable = true;

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "hyprland";
    compositor.customConfig = ''
      env = XCURSOR_SIZE,24
      env = XCURSOR_THEME,catppuccin-mocha-blue-cursors
      exec-once = hyprctl setcursor catppuccin-mocha-blue-cursors 24
    '';
    configHome = config.users.users.augusto.home;
  };

  environment.systemPackages = [
    pkgs.catppuccin-cursors.mochaBlue
    pkgs.papirus-icon-theme
  ];
}
