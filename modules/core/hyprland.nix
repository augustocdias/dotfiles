# Hyprland compositor system configuration
{...}: {
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Required environment variables for Wayland
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  # Enable dconf (required for some Wayland apps)
  programs.dconf.enable = true;
  programs.direnv.enable = true;
}
