{
  den,
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.jetbrains-plugins = {
    url = lib.mkDefault "github:Janrupf/nix-jetbrains-plugin-repository";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.datagrip = {
    includes = [
      (den.lib.perHost {
        nixos = {
          nixpkgs.overlays = lib.optionals (inputs ? jetbrains-plugins) [
            inputs.jetbrains-plugins.overlays.default
          ];
        };
      })
    ];

    homeManager = {pkgs, ...}: {
      home.packages = [
        (pkgs.jetbrains-plugins.lib.buildIdeWithPlugins pkgs.jetbrains.datagrip (with pkgs.jetbrains-plugins; [
          IdeaVIM
          com.intellij.ml.llm
          com.intellij.mcpServer
          aws.toolkit.core
          aws.toolkit
          com.github.catppuccin.jetbrains
        ]))
      ];
    };
  };
}
