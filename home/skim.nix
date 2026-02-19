{...}: {
  programs.skim = {
    enable = true;
    enableFishIntegration = true;

    defaultCommand = "rg --files --no-ignore-exclude";
    changeDirWidgetCommand = "fd --type d";

    defaultOptions = [
      "--layout=reverse"
      "--inline-info"
      "--multi"
      "--preview='bat --style=numbers --color=always {} 2>/dev/null || echo Not a file'"
      "--preview-window=right:50%"
      "'--bind=alt-r:execute(bat {}),alt-p:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept'"
      "--color=catppuccin-mocha"
    ];

    fileWidgetOptions = [
      "--preview='bat --style=numbers --color=always {} 2>/dev/null || echo Not a file'"
    ];

    changeDirWidgetOptions = [
      "--preview='eza --tree --level=2 --color=always {}'"
    ];

    historyWidgetOptions = [
      "--preview-window=:hidden"
    ];
  };
}
