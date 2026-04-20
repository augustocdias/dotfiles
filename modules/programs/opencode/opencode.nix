{
  den,
  lib,
  ...
}: let
  nvim-mcp-wrapper = pkgs:
    pkgs.writeShellScriptBin "nvim-mcp" ''
      session="''${ZELLIJ_SESSION_NAME:-dettached}"
      export NVIM_ADDRESS="$HOME/.cache/nvim/server-''${session}.pipe"
      exec ${lib.getExe' pkgs.uv "uvx"} nvim-mcp "$@"
    '';
in {
  den.aspects.opencode = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      # FIXME: xdg.configFile creates symlinks into /nix/store which breaks Bun's
      # module resolution for @opencode-ai/plugin (it resolves relative to the real
      # path, not the symlink). We copy the files instead until this is fixed upstream.
      # https://github.com/anomalyco/opencode/issues/5914
      home.activation.opencode-tools = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p $HOME/.config/opencode/tools
        cp -f ${./tools/date.ts} $HOME/.config/opencode/tools/date.ts
        cp -f ${./tools/gh.ts} $HOME/.config/opencode/tools/gh.ts
        cp -f ${./tools/google_calendar.ts} $HOME/.config/opencode/tools/google_calendar.ts
      '';

      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;

        tui = {
          theme = "catppuccin-macchiato";
        };

        context = ''
          # Global Instructions

          ## Interaction Style
          - Tone: direct and informal, like a senior colleague in a code review
          - Default to short answers (1-3 paragraphs). Only give longer responses when the question demands it
          - Be honest about capabilities and limitations
          - Challenge incorrect assumptions with clear reasoning
          - Don't apologize excessively or repeat the question back before answering
          - If a request is ambiguous, ask for clarification rather than guessing
          - Don't generate placeholder implementations as final answers — mark scaffolding clearly

          ## Neovim Integration
          When the nvim MCP server is available:
          - **Always use nvim MCP tools over native read/write tools** for reading and editing files
          - Use nvim tools to see what the user sees: open buffers, cursor position, diagnostics, selections
          - Use nvim tools for buffer edits — changes are immediate with full undo support
          - Use nvim tools to query LSP diagnostics across buffers
          - Fall back to native read/write tools only if the nvim MCP server is unavailable
          - The nvim MCP server auto-connects to the neovim instance in the current zellij session
            via a socket at ~/.cache/nvim/server-<ZELLIJ_SESSION_NAME>.pipe
          - **CRITICAL: Before editing any file, display it in the rightmost neovim window without
            disrupting the user's cursor.** Run via nvim_send_command:
            `lua require('utils').show_in_rightmost('<filepath>', <line>)` (line is optional)
            Then perform the edit with nvim_find_and_replace_buf.
            After editing, save with:
            `lua require('utils').save_buf('<filepath>')`
            Always pass paths relative to the workspace root (same path used in nvim_find_and_replace_buf).

          ## Citations & Sources
          - Use context7 to fetch current documentation before explaining library/API behavior
          - Provide links to official docs or authoritative sources for technical claims
          - If no source is available, state the claim is based on general knowledge and may need verification
          - Never present unverified information as fact
        '';

        settings = {
          model = "anthropic/claude-opus-4-7";
          autoupdate = false;
          default_agent = "plan";
          lsp = false;

          provider = {
            anthropic.options.apiKey = "{env:ANTHROPIC_API_KEY}";
            openai.options.apiKey = "{env:OPENAI_API_KEY}";
          };

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
              environment.DEFAULT_MINIMUM_TOKENS = "64000";
            };
            datadog = {
              type = "remote";
              url = "https://mcp.datadoghq.eu/api/unstable/mcp-server/mcp";
            };
            nvim = {
              type = "local";
              command = ["${(nvim-mcp-wrapper pkgs)}/bin/nvim-mcp"];
            };
            nixos = {
              type = "local";
              command = ["nix" "run" "github:utensils/mcp-nixos" "--"];
            };
          };

          permission = {
            # --- Custom tools ---------------------------------------------------
            gh_issue_read = "allow";
            gh_issue_write = "ask";
            gh_pr_read = "allow";
            gh_pr_write = "ask";
            gh_workflow_read = "allow";
            gh_workflow_write = "ask";
            gh_run_read = "allow";
            gh_run_write = "ask";
            gh_search = "allow";
            gh_status = "allow";
            gh_repo_read = "allow";
            gh_repo_write = "ask";
            google_calendar = "allow";
            date = "allow";

            # --- Bash -----------------------------------------------------------
            bash = {
              "*" = "ask";

              # -- Git: core read-only -------------------------------------------
              "git status*" = "allow";
              "git log*" = "allow";
              "git show*" = "allow";
              "git diff*" = "allow";
              "git blame*" = "allow";
              "git reflog*" = "allow";
              "git describe*" = "allow";
              "git shortlog*" = "allow";
              "git whatchanged*" = "allow";

              # -- Git: plumbing / inspection ------------------------------------
              "git rev-parse*" = "allow";
              "git symbolic-ref*" = "allow";
              "git ls-files*" = "allow";
              "git ls-remote*" = "allow";
              "git ls-tree*" = "allow";
              "git cat-file*" = "allow";
              "git rev-list*" = "allow";
              "git name-rev*" = "allow";
              "git merge-base*" = "allow";
              "git count-objects*" = "allow";
              "git fsck*" = "allow";
              "git verify-commit*" = "allow";
              "git verify-tag*" = "allow";
              "git check-ignore*" = "allow";
              "git check-attr*" = "allow";
              "git check-mailmap*" = "allow";
              "git for-each-ref*" = "allow";
              "git hash-object*" = "allow";

              # -- Git: misc read-only -------------------------------------------
              "git archive*" = "allow";
              "git bundle*" = "allow";
              "git help*" = "allow";
              "git --version*" = "allow";

              # -- Git: conditional read-only (with flags) -----------------------
              "git branch --list*" = "allow";
              "git branch -l*" = "allow";
              "git branch --show-current*" = "allow";
              "git branch --contains*" = "allow";
              "git branch --merged*" = "allow";
              "git branch --no-merged*" = "allow";
              "git remote -v*" = "allow";
              "git remote show*" = "allow";
              "git remote get-url*" = "allow";
              "git tag --list*" = "allow";
              "git tag -l*" = "allow";
              "git tag --contains*" = "allow";
              "git tag --merged*" = "allow";
              "git tag --points-at*" = "allow";
              "git config --get*" = "allow";
              "git config --get-all*" = "allow";
              "git config --get-regexp*" = "allow";
              "git config --list*" = "allow";
              "git config -l*" = "allow";
              "git stash list*" = "allow";
              "git stash show*" = "allow";
              "git worktree list*" = "allow";

              # -- File / directory inspection -----------------------------------
              "ls*" = "allow";
              "eza*" = "allow";
              "tree*" = "allow";
              "cat *" = "allow";
              "bat *" = "allow";
              "head *" = "allow";
              "tail *" = "allow";
              "wc *" = "allow";
              "file *" = "allow";
              "stat *" = "allow";
              "du *" = "allow";
              "df *" = "allow";
              "readlink *" = "allow";

              # -- Search --------------------------------------------------------
              "rg *" = "allow";
              "fd *" = "allow";
              "find *" = "allow";
              "grep *" = "allow";
              "which *" = "allow";
              "whereis *" = "allow";
              "type *" = "allow";

              # -- Text processing (read-only) -----------------------------------
              "sort *" = "allow";
              "uniq *" = "allow";
              "diff *" = "allow";
              "comm *" = "allow";
              "cut *" = "allow";
              "tr *" = "allow";
              "awk *" = "allow";
              "sed -n*" = "allow";
              "jq *" = "allow";
              "yq *" = "allow";
              "column *" = "allow";
              "tac *" = "allow";
              "rev *" = "allow";
              "paste *" = "allow";
              "expand *" = "allow";
              "unexpand *" = "allow";
              "fold *" = "allow";
              "fmt *" = "allow";
              "nl *" = "allow";

              # -- System info ---------------------------------------------------
              "uname*" = "allow";
              "hostname*" = "allow";
              "whoami*" = "allow";
              "id*" = "allow";
              "env*" = "allow";
              "printenv*" = "allow";
              "date*" = "allow";
              "uptime*" = "allow";
              "pwd*" = "allow";
              "locale*" = "allow";
              "getconf*" = "allow";

              # -- Process inspection --------------------------------------------
              "ps *" = "allow";
              "pgrep *" = "allow";

              # -- Network (read-only) -------------------------------------------
              "curl *" = "allow";
              "dig *" = "allow";
              "nslookup *" = "allow";
              "ping *" = "allow";
              "host *" = "allow";

              # -- Cargo / Rust --------------------------------------------------
              "cargo check*" = "allow";
              "cargo test*" = "allow";
              "cargo clippy*" = "allow";
              "cargo build*" = "allow";
              "cargo doc*" = "allow";
              "cargo fmt --check*" = "allow";
              "cargo tree*" = "allow";
              "cargo metadata*" = "allow";
              "cargo pkgid*" = "allow";
              "cargo verify-project*" = "allow";
              "cargo bench*" = "allow";
              "rustc --version*" = "allow";
              "rustc --explain*" = "allow";
              "rustup show*" = "allow";
              "rustup target list*" = "allow";
              "rustup toolchain list*" = "allow";

              # -- Node / JS -----------------------------------------------------
              "node --version*" = "allow";
              "node -e*" = "allow";
              "npm list*" = "allow";
              "npm info*" = "allow";
              "npm view*" = "allow";
              "npm ls*" = "allow";
              "npm outdated*" = "allow";
              "npm audit*" = "allow";
              "npm explain*" = "allow";
              "pnpm list*" = "allow";
              "pnpm info*" = "allow";
              "pnpm outdated*" = "allow";
              "pnpm audit*" = "allow";
              "npx --version*" = "allow";

              # -- Python --------------------------------------------------------
              "python3 --version*" = "allow";
              "python3 -c*" = "allow";

              # -- Nix -----------------------------------------------------------
              "nix eval*" = "allow";
              "nix flake show*" = "allow";
              "nix flake metadata*" = "allow";
              "nix flake info*" = "allow";
              "nix-info*" = "allow";
              "nix path-info*" = "allow";
              "nix show-derivation*" = "allow";
              "nix-store --query*" = "allow";

              # -- Just ----------------------------------------------------------
              "just --list*" = "allow";
              "just --summary*" = "allow";
              "just --show*" = "allow";
              "just --evaluate*" = "allow";
              "just --dump*" = "allow";

              # -- GH CLI (read-only, supplements custom tools) ------------------
              "gh issue list*" = "allow";
              "gh issue view*" = "allow";
              "gh issue status*" = "allow";
              "gh pr list*" = "allow";
              "gh pr view*" = "allow";
              "gh pr diff*" = "allow";
              "gh pr checks*" = "allow";
              "gh pr status*" = "allow";
              "gh repo view*" = "allow";
              "gh repo list*" = "allow";
              "gh run list*" = "allow";
              "gh run view*" = "allow";
              "gh run watch*" = "allow";
              "gh workflow list*" = "allow";
              "gh workflow view*" = "allow";
              "gh search *" = "allow";
              "gh status*" = "allow";
              "gh auth status*" = "allow";
              "gh api *" = "allow";
            };
          };
        };
      };
    };
  };
}
