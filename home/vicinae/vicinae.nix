{
  pkgs,
  lib,
  inputs,
  ...
}: let
  extensions = import ./extensions.nix {inherit pkgs lib inputs;};

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
  xdg.configFile."vicinae/settings.json".text = builtins.toJSON {
    "$schema" = "https://vicinae.com/schemas/config.json";

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

    launcher_window = {
      layer_shell = {
        enabled = true;
        keyboard_interactivity = "exclusive";
        layer = "overlay";
      };
    };
  };

  xdg.dataFile = vicinaeDataFiles // raycastDataFiles;
}
