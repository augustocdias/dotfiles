{
  pkgs,
  lib,
  ...
}: let
  # Import all plugins from sources
  customPlugins = import ./plugins.nix {inherit pkgs lib;};
in {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    vimAlias = true;
    viAlias = true;

    # Include all plugins from our sources
    plugins =
      customPlugins.pluginList
      ++ [
        # Add nvim-treesitter with grammars
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (p:
          with p; [
            bash
            c
            comment
            cpp
            c_sharp
            css
            diff
            dockerfile
            editorconfig
            fish
            gdscript
            godot_resource
            gdshader
            git_config
            git_rebase
            gitattributes
            gitcommit
            gitignore
            html
            java
            javascript
            jsdoc
            json
            json5
            kdl
            kotlin
            lua
            luadoc
            markdown
            markdown_inline
            nix
            python
            qmljs
            query
            regex
            rust
            sql
            swift
            toml
            typescript
            tsx
            vim
            vimdoc
            yaml
          ]))
      ];

    # LSP servers and tools
    extraPackages = with pkgs; [
      # LSP servers
      bash-language-server
      yaml-language-server
      vscode-json-languageserver
      dockerfile-language-server
      docker-compose-language-service
      taplo # TOML
      emmylua-ls
      typescript
      rust-analyzer
      nixd

      # Formatters
      black
      stylua
      prettier
      shfmt
      alejandra
      sqlfluff

      # Linters
      harper # Grammar checker
      eslint
      codespell
      selene
      yamllint
      hadolint
      actionlint
      deadnix
      write-good

      # code actions
      statix
    ];
  };

  # Copy Lua configuration files
  xdg.configFile."nvim" = {
    source = ../configs/neovim;
    recursive = true;
  };
  # Copy mcp-hub config
  xdg.configFile."mcphub" = {
    source = ../configs/mcphub;
    recursive = true;
  };

  # Set editor environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
