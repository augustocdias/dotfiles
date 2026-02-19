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
      nelly_gh_registry_token = {};
      jira_token = {};
      dd_app_key = {};
      dd_api_key = {};
    };

    templates."env-secrets.fish" = {
      path = "%r/env-secrets.fish";
      content = ''
        set -gx ANTHROPIC_API_KEY ${config.sops.placeholder.anthropic_api_key}
        set -gx GOOGLE_SEARCH_API_KEY ${config.sops.placeholder.google_search_api_key}
        set -gx GOOGLE_SEARCH_ENGINE_ID ${config.sops.placeholder.google_search_engine_id}
        set -gx TAVILY_API_KEY ${config.sops.placeholder.tavily_api_key}
        set -gx NELLY_GH_REGISTRY_TOKEN ${config.sops.placeholder.nelly_gh_registry_token}
        set -gx JIRA_TOKEN ${config.sops.placeholder.jira_token}
        set -gx DD_APP_KEY ${config.sops.placeholder.dd_app_key}
        set -gx DD_API_KEY ${config.sops.placeholder.dd_api_key}
      '';
    };
  };
}
