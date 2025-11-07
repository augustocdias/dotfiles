# Vicinae launcher configuration
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  extensions = import ./extensions.nix {inherit pkgs lib inputs;};

  # Convert extension lists to xdg.dataFile format
  vicinaeDataFiles = builtins.listToAttrs (map (ext: {
      name = "vicinae/extensions/store.vicinae.${ext.name}";
      value = {
        source = ext.pkg;
        recursive = true;
      };
    })
    extensions.vicinaePackages);

  raycastDataFiles = builtins.listToAttrs (map (ext: {
      name = "vicinae/extensions/store.raycast-compat.${ext.name}";
      value = {
        source = ext.pkg;
        recursive = true;
      };
    })
    extensions.raycastPackages);
in {
  # Vicinae settings - merged with defaults
  xdg.configFile."vicinae/settings.json".text = builtins.toJSON {
    "$schema" = "https://vicinae.com/schemas/config.json";

    # Theme - catppuccin mocha to match the rest of the system
    theme = {
      light = {
        name = "catppuccin-latte";
        icon_theme = "auto";
      };
      dark = {
        name = "catppuccin-mocha";
        icon_theme = "auto";
      };
    };

    # Window settings
    launcher_window = {
      layer_shell = {
        enabled = true;
        keyboard_interactivity = "exclusive";
        layer = "overlay";
      };
    };
  };

  # Install all extensions
  xdg.dataFile = vicinaeDataFiles // raycastDataFiles;
}
