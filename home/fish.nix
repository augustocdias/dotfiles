# Fish shell configuration with plugins
{pkgs, ...}: let
in {
  # Environment variables - set using Home Manager's native support
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    # Theme settings
    BAT_THEME = "Catppuccin Mocha";

    # FZF configuration
    FZF_DEFAULT_COMMAND = "rg --files --no-ignore-exclude";
    FZF_ALT_C_COMMAND = "fd --type d";
    FZF_PREVIEW_DIR_CMD = "eza";
    DD_SITE = "datadoghq.eu";
    JIRA_URL = "https://nelly.atlassian.net";

    GITHUB_USER = "augustocdias";
    SEARXNG_API_URL = "https://searx.oloke.xyz/";
  };

  programs.fish = {
    enable = true;

    plugins = [
      # Plugins available in nixpkgs
      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }

      # Custom plugins from GitHub (pinned to commit SHAs for reproducibility)
      {
        name = "enhancd";
        src = builtins.fetchGit {
          url = "https://github.com/babarot/enhancd";
          rev = "5afb4eb6ba36c15821de6e39c0a7bb9d6b0ba415";
        };
      }
      {
        name = "plugin-wttr";
        src = builtins.fetchGit {
          url = "https://github.com/oh-my-fish/plugin-wttr";
          rev = "7500e382e6b29a463edc57598217ce0cfaf8c90c";
        };
      }
    ];

    # Shell initialization
    shellInit = ''
      # Non-interactive shell initialization
    '';

    # Interactive shell configuration
    interactiveShellInit = ''
      # Source the main initialization script
      source ${./configs/fish/init.fish}
    '';

    # Shell aliases
    shellAliases = {
      # File listing
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";

      # Tool replacements
      cat = "bat";
      grep = "rg";

      # Editor shortcuts
      v = "nvim";
      vim = "nvim";

      # NixOS operations (nix-rebuild is a function, see below)
      nix-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      nix-flake-update = "nix flake update --flake ~/nixos";
      nix-check = "nix flake check ~/nixos";
      nix-history = "sudo nix profile history --profile /nix/var/nix/profiles/system";
      nix-rollback = "sudo nixos-rebuild switch --rollback";
      nix-preview = "nixos-rebuild build --flake ~/nixos#augusto -o /tmp/nixos-preview && nix store diff-closures /run/current-system /tmp/nixos-preview";

      # Lock screen
      afk = "dms ipc call lock lock";
    };

    # Fish functions
    functions = {
      nix-rebuild = ''
        if test "$argv[1]" = "--home"
          nix run home-manager -- switch --flake ~/nixos#augusto
        else
          sudo nixos-rebuild switch --flake ~/nixos#augusto $argv
        end
      '';
    };

    # Shell abbreviations from abbreviations.fish
    shellAbbrs = {
      # Git abbreviations
      g = "git";
      gco = "git co";
      gm = "git cm";
      ga = "git a";
      gaa = "git aa";
      gp = "git pull origin";
      gu = "git push origin";
      gsb = "git status -sb";

      # pnpm abbreviations
      p = "pnpm";
      pi = "pnpm install";
      pd = "pnpm dev";

      # LLM abbreviations
      lc = "llm commit";
      lcy = "llm commit --yes";
    };
  };
}
