{...}: {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      theme = "catppuccin-macchiato";
      model = "anthropic/claude-opus-4-6";
      autoupdate = false;
      default_agent = "plan";
      lsp = false;

      mcp = {
        Notion = {
          type = "remote";
          url = "https://mcp.notion.com/mcp";
        };
        linear = {
          type = "local";
          command = ["npx" "-y" "mcp-remote" "https://mcp.linear.app/mcp"];
        };
        context7 = {
          type = "local";
          command = ["npx" "-y" "@upstash/context7-mcp"];
          environment = {
            DEFAULT_MINIMUM_TOKENS = "64000";
          };
        };
        datadog = {
          type = "remote";
          url = "https://mcp.datadoghq.eu/api/unstable/mcp-server/mcp";
        };
      };
    };
  };
}
