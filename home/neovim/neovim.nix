{
  pkgs,
  lib,
  ...
}: let
  customPlugins = import ./plugins.nix {inherit pkgs lib;};
in {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    vimAlias = true;
    viAlias = true;

    plugins =
      customPlugins.pluginList
      ++ [
        # treesitter from nixpkgs because of the grammars
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
      harper # linter but hooks as lsp server
      eslint
      codespell
      selene
      yamllint
      hadolint
      actionlint
      deadnix
      write-good
      markdownlint-cli
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
