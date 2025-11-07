# Kitty terminal emulator configuration
{...}: let
in {
  programs.kitty = {
    enable = true;

    # Catppuccin Mocha theme (built-in)
    themeFile = "Catppuccin-Mocha";

    # Font configuration
    font = {
      name = "MonaspiceNe Nerd Font";
      size = 12;
    };

    settings = {
      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = 0;
      cursor_trail = 1;

      # Fonts
      bold_font = "auto";
      italic_font = "MonaspiceRn Nerd Font Light Italic";
      bold_italic_font = "auto";
      modify_font = "baseline 1";
      disable_ligatures = "never";

      # Tabs
      tab_bar_style = "powerline";
      tab_title_template = "{index}:{title}";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      # Clipboard
      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";
      clipboard_control = "write-clipboard write-primary";

      # Window
      background_opacity = "0.90";
      window_border_width = 0;
      draw_minimal_borders = "no";

      # Mouse
      mouse_hide_wait = "2.0";
      detect_urls = "yes";
      open_url_with = "default";
    };

    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+[" = "launch --location=hsplit --cwd=current";
      "ctrl+shift+]" = "launch --location=vsplit --cwd=current";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+c" = "copy_to_clipboard";

      # macOS-style shortcuts
      "super+c" = "copy_to_clipboard";
      "super+v" = "paste_from_clipboard";
      "super+t" = "new_tab_with_cwd";
      "super+w" = "close_tab";
      "super+n" = "new_os_window_with_cwd";
    };
  };
}
