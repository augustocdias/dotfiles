# Display manager configuration
{pkgs, ...}: {
  qt.enable = true;

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "hyprland";
    compositor.customConfig = ''
      env = XCURSOR_SIZE,24
      env = XCURSOR_THEME,catppuccin-mocha-blue-cursors
      exec-once = hyprctl setcursor catppuccin-mocha-blue-cursors 24
    '';
    configHome = "/home/augusto";
  };

  # Install cursor and icon themes system-wide
  environment.systemPackages = [
    pkgs.catppuccin-cursors.mochaBlue
    pkgs.papirus-icon-theme
  ];
}
