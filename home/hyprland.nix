{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = true;
    systemd.variables = ["all"];

    settings = {
      # ===== MONITORS =====
      monitor = ",preferred,auto,1";

      # ===== AUTOSTART =====
      exec-once = [
        "dms run"
        "vicinae server"
        "hyprpolkitagent"
        # "mpvpaper -n 1800 -o '--shuffle --keepaspect=no' '*' ~/media/animated"
      ];

      # ===== ENVIRONMENT VARIABLES =====
      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,catppuccin-mocha-blue-cursors"
        "QT_QPA_PLATFORMTHEME,hyprqt6engine"
        "QT_QUICK_CONTROLS_STYLE,org.hyprland.style"
      ];

      # ===== VISUAL =====
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        # Catppuccin Mocha: blue to teal gradient
        "col.active_border" = "rgba(89b4faee) rgba(94e2d5ee) 45deg";
        # Catppuccin Mocha: surface2
        "col.inactive_border" = "rgba(585b70aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 8;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          # Catppuccin Mocha: crust
          color = "rgba(11111bee)";
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      gestures = {
        gesture = "3, horizontal, workspace";

        # 4-finger swipe up for overview (qs-hyprview) FIXME:
        # gesture = 4, up, exec, quickshell ipc -c qs-hyprview call expose toggle masonry
        # 4-finger pinch to toggle floating FIXME:
        # gesture = 4, pinch, togglefloating,
      };

      # ===== INPUT =====
      input = {
        kb_layout = "us";
        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
          clickfinger_behavior = true;
        };

        sensitivity = 0;
      };

      # ===== VARIABLES =====
      "$mainMod" = "SUPER";

      # ===== KEYBINDINGS =====
      bind = [
        # Applications
        "$mainMod, RETURN, exec, kitty"
        "$mainMod, SPACE, exec, vicinae toggle"
        "$mainMod, Q, killactive,"
        "$mainMod SHIFT, SPACE, exec, dms ipc call powermenu toggle"

        # Screenshots
        ", PRINT, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, PRINT, exec, grim - | wl-copy"
        "$mainMod, PRINT, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"

        # Lock screen
        "$mainMod SHIFT, L, exec, dms ipc call lock lock"

        # Media controls
        ", XF86AudioPlay, exec, dms ipc call media play-pause"
        ", XF86AudioPause, exec, dms ipc call media play-pause"
        ", XF86AudioPrev, exec, dms ipc call media previous"
        ", XF86AudioNext, exec, dms ipc call media next"

        # Volume control
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        # Brightness control
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

        # Window focus
        "$mainMod ALT, J, movefocus, d"
        "$mainMod ALT, K, movefocus, u"
        "$mainMod ALT, H, movefocus, l"
        "$mainMod ALT, L, movefocus, r"

        "$mainMod CTRL ALT, H, focusmonitor, -1"
        "$mainMod CTRL ALT, L, focusmonitor, +1"

        # Window switching
        "$mainMod, TAB, cyclenext,"
        "$mainMod, TAB, alterzorder, top"
        "$mainMod SHIFT, TAB, cyclenext, prev"
        "$mainMod SHIFT, TAB, alterzorder, top"

        "ALT, TAB, cyclenext, , , currentworkspace"
        "ALT, TAB, alterzorder, top"
        "ALT SHIFT, TAB, cyclenext, prev, , currentworkspace"
        "ALT SHIFT, TAB, alterzorder, top"

        # Layout modifications
        "$mainMod CTRL ALT, R, layoutmsg, orientationnext"
        "$mainMod CTRL ALT, T, togglefloating,"
        "$mainMod CTRL ALT, T, centerwindow,"

        # Window size
        "$mainMod CTRL ALT, RETURN, fullscreen, 1"
        "$mainMod SHIFT ALT, RETURN, fullscreen, 0"

        # Moving windows
        "$mainMod CTRL, J, swapwindow, d"
        "$mainMod CTRL, K, swapwindow, u"
        "$mainMod CTRL, H, swapwindow, l"
        "$mainMod CTRL, L, swapwindow, r"

        "$mainMod CTRL ALT, LEFT, movewindow, mon:-1"
        "$mainMod CTRL ALT, LEFT, focusmonitor, -1"
        "$mainMod CTRL ALT, RIGHT, movewindow, mon:+1"
        "$mainMod CTRL ALT, RIGHT, focusmonitor, +1"

        "$mainMod ALT, P, movetoworkspace, -1"
        "$mainMod ALT, N, movetoworkspace, +1"

        # Silent workspace moves
        "$mainMod CTRL, 1, movetoworkspacesilent, 1"
        "$mainMod CTRL, 2, movetoworkspacesilent, 2"
        "$mainMod CTRL, 3, movetoworkspacesilent, 3"
        "$mainMod CTRL, 4, movetoworkspacesilent, 4"
        "$mainMod CTRL, 5, movetoworkspacesilent, 5"
        "$mainMod CTRL, 6, movetoworkspacesilent, 6"
        "$mainMod CTRL, 7, movetoworkspacesilent, 7"
        "$mainMod CTRL, 8, movetoworkspacesilent, 8"
        "$mainMod CTRL, 9, movetoworkspacesilent, 9"
        "$mainMod CTRL, 0, movetoworkspacesilent, 10"

        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Scroll workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Special workspace (scratchpad)
        "$mainMod, H, togglespecialworkspace, scratchpad"
        "$mainMod SHIFT, H, movetoworkspace, special:scratchpad"
        "$mainMod SHIFT, N, workspace, empty"

        # Hyprland control
        "$mainMod SHIFT CTRL ALT, R, exec, hyprctl reload"
      ];

      # Bindings with repeat (binde)
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # ===== WINDOW RULES =====
      windowrule = [
        # Floating windows
        "float on, match:class ^(pavucontrol)$"
        "float on, match:class ^(nm-connection-editor)$"
        "float on, match:title ^(Picture-in-Picture)$"
        "pin on, match:title ^(Picture-in-Picture)$"

        # Opacity rules
        "opacity 0.95 0.95, match:class ^(wezterm)$"
        "opacity 0.9 0.9, match:class ^(Code)$"

        # Firefox picture-in-picture
        "size 640 360, match:title ^(Picture-in-Picture)$"
        "move 100%-w-20 100%-w-20, match:title ^(Picture-in-Picture)$"
      ];
    };

    # Resize submap - must use extraConfig due to submap boundary syntax
    extraConfig = ''
      # Enter resize mode with Super+Alt+R
      bind = $mainMod ALT, r, submap, resize

      submap = resize

      # Arrows (10px steps)
      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      binde = , up, resizeactive, 0 -10
      binde = , down, resizeactive, 0 10

      # Vim keys (10px steps)
      binde = , l, resizeactive, 10 0
      binde = , h, resizeactive, -10 0
      binde = , k, resizeactive, 0 -10
      binde = , j, resizeactive, 0 10

      # Shift + arrows (5px steps)
      binde = SHIFT, right, resizeactive, 5 0
      binde = SHIFT, left, resizeactive, -5 0
      binde = SHIFT, up, resizeactive, 0 -5
      binde = SHIFT, down, resizeactive, 0 5

      # Shift + vim keys (5px steps)
      binde = SHIFT, l, resizeactive, 5 0
      binde = SHIFT, h, resizeactive, -5 0
      binde = SHIFT, k, resizeactive, 0 -5
      binde = SHIFT, j, resizeactive, 0 5

      # Ignore modifier keys (prevent catchall from triggering)
      bind = , Shift_L, exec,
      bind = , Shift_R, exec,

      # Exit resize mode
      bind = , escape, submap, reset
      bind = , catchall, submap, reset

      submap = reset
    '';
  };

  # Set cursor theme for GTK and other applications
  home.pointerCursor = {
    name = "catppuccin-mocha-blue-cursors";
    package = pkgs.catppuccin-cursors.mochaBlue;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
