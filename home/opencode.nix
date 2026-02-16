# OpenCode AI coding agent configuration
{...}: {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      theme = "catppuccin-macchiato";
      model = "anthropic/claude-opus-4-5";
      autoupdate = false;
      default_agent = "plan";

      mcp = {
        Notion = {
          type = "remote";
          url = "https://mcp.notion.com/mcp";
        };
        atlassian = {
          type = "local";
          command = ["npx" "-y" "mcp-remote" "https://mcp.atlassian.com/v1/sse"];
        };
        context7 = {
          type = "local";
          command = ["npx" "-y" "@upstash/context7-mcp"];
          environment = {
            DEFAULT_MINIMUM_TOKENS = "64000";
          };
        };
        memory = {
          type = "local";
          command = ["npx" "-y" "@modelcontextprotocol/server-memory"];
        };
        datadog = {
          type = "remote";
          url = "https://mcp.datadoghq.eu/api/unstable/mcp-server/mcp";
        };
      };
    };
  };
}
