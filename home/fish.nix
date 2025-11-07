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

      # Custom plugins from GitHub
      {
        name = "enhancd";
        src = pkgs.fetchFromGitHub {
          owner = "babarot";
          repo = "enhancd";
          rev = "main";
          sha256 = "09wa6s36xlyzbakgqadcjk4g2rzinp2l3irn8ikagl445b11p954";
        };
      }
      {
        name = "plugin-wttr";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-wttr";
          rev = "master";
          sha256 = "sha256-k3FrRPxKCiObO6HgtDx8ORbcLmfSYQsQeq5SAoNfZbE=";
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

      # NixOS operations
      nix-rebuild = "sudo nixos-rebuild switch --flake ~/nixos#augusto";
      nix-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      nix-flake-update = "nix flake update --flake ~/nixos";
      nix-check = "nix flake check ~/nixos";
      nix-history = "sudo nix profile history --profile /nix/var/nix/profiles/system";
      nix-rollback = "sudo nixos-rebuild switch --rollback";
      nix-preview = "nixos-rebuild build --flake ~/nixos#augusto -o /tmp/nixos-preview && nix store diff-closures /run/current-system /tmp/nixos-preview";

      # Lock screen
      afk = "dms ipc call lock lock";
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
