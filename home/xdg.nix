# XDG user directories and MIME applications configuration
{config, ...}: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;
    documents = "${config.home.homeDirectory}/documents";
    download = "${config.home.homeDirectory}/downloads";
    music = null;
    pictures = "${config.home.homeDirectory}/pictures";
    publicShare = null;
    templates = null;
    videos = null;
    extraConfig = {
      DEV = "${config.home.homeDirectory}/dev";
      SCREENSHOTS = "${config.home.homeDirectory}/pictures/screenshots";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Web
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";

      # PDF
      "application/pdf" = "firefox.desktop";

      # Images
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";

      # Video
      "video/mp4" = "mpv.desktop";
      "video/mkv" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/avi" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";

      # Audio
      "audio/mpeg" = "mpv.desktop";
      "audio/mp3" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/x-wav" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";

      # Archives
      "application/zip" = "peazip.desktop";
      "application/x-tar" = "peazip.desktop";
      "application/gzip" = "peazip.desktop";
      "application/x-gzip" = "peazip.desktop";
      "application/x-bzip2" = "peazip.desktop";
      "application/x-xz" = "peazip.desktop";
      "application/x-7z-compressed" = "peazip.desktop";
      "application/x-rar-compressed" = "peazip.desktop";
      "application/vnd.rar" = "peazip.desktop";

      # Text files
      "text/plain" = "neovide.desktop";
      "text/x-script.python" = "neovide.desktop";
      "application/x-shellscript" = "neovide.desktop";
      "application/json" = "neovide.desktop";
      "application/xml" = "neovide.desktop";
      "text/xml" = "neovide.desktop";
      "text/x-c" = "neovide.desktop";
      "text/x-c++" = "neovide.desktop";
      "text/x-java" = "neovide.desktop";
      "text/x-rust" = "neovide.desktop";
      "text/x-go" = "neovide.desktop";
      "text/markdown" = "neovide.desktop";

      # Email
      "x-scheme-handler/mailto" = "thunderbird.desktop";
      "message/rfc822" = "thunderbird.desktop";
    };
  };
}
