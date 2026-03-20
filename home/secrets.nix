{
  config,
  pkgs,
  ...
}: let
  sops-setup = pkgs.writeScriptBin "sops-setup" (builtins.readFile ./secrets/sops-setup.fish);
in {
  home.packages = [sops-setup];

  sops = {
    defaultSopsFile = ./secrets/env.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      anthropic_api_key = {};
      google_search_api_key = {};
      google_search_engine_id = {};
      tavily_api_key = {};
      dd_app_key = {};
      dd_api_key = {};
      github_token = {};
    };

    templates = {
      "env-secrets.fish" = {
        path = "%r/env-secrets.fish";
        content = ''
          set -gx ANTHROPIC_API_KEY ${config.sops.placeholder.anthropic_api_key}
          set -gx GOOGLE_SEARCH_API_KEY ${config.sops.placeholder.google_search_api_key}
          set -gx GOOGLE_SEARCH_ENGINE_ID ${config.sops.placeholder.google_search_engine_id}
          set -gx TAVILY_API_KEY ${config.sops.placeholder.tavily_api_key}
          set -gx DD_APP_KEY ${config.sops.placeholder.dd_app_key}
          set -gx DD_API_KEY ${config.sops.placeholder.dd_api_key}
        '';
      };
      "dms-env" = {
        path = "%r/dms-env";
        content = ''
          ANTHROPIC_API_KEY=${config.sops.placeholder.anthropic_api_key}
        '';
      };
      # TODO: migrate sops to nixos level to have this token available to the
      # nix daemon. workaround for now is pass the following if getting 403s
      # from github: --option access-tokens (nix config show access-tokens)
      "nix-conf" = {
        path = "${config.home.homeDirectory}/.config/nix/nix.conf";
        content = ''
          access-tokens = github.com=${config.sops.placeholder.github_token}
        '';
      };
    };
  };
}
