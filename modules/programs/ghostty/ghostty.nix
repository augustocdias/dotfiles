{den, ...}: {
  den.aspects.ghostty = {
    homeManager = {config, ...}: {
      programs.ghostty = {
        enable = true;

        settings = {
          # Theme
          theme = "Catppuccin Mocha";

          # Font configuration
          font-family = "MonaspiceNe Nerd Font";
          font-family-italic = "MonaspiceRn Nerd Font Light Italic";
          font-size = 12;

          # Cursor
          cursor-style = "block";
          cursor-style-blink = false;

          # Window appearance
          background-opacity = 0.8;

          # Features
          copy-on-select = true;
          shell-integration = "detect";

          # Mouse behavior
          mouse-hide-while-typing = true;

          # Systemd integration
          gtk-single-instance = true;
          linux-cgroup = "single-instance";
          linux-cgroup-memory-limit = 25769803776;  # 24GB limit
          linux-cgroup-processes-limit = 4096;  # Increased for Neovim
          linux-cgroup-hard-fail = false;

          # Custom shader for cursor trail
          custom-shader = "${config.xdg.configHome}/ghostty/shaders/cursor-trail.glsl";
          custom-shader-animation = true;
        };
      };

      # Symlink the cursor trail shader
      xdg.configFile."ghostty/shaders/cursor-trail.glsl".source = ./cursor-trail.glsl;
    };
  };
}

