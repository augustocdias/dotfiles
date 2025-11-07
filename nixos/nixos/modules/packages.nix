# packages.nix - System packages
{
  config,
  pkgs,
  vicinae,
  awww,
  neovim-nightly-overlay,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # ===== EDITORS =====
    neovim-nightly-overlay.packages.${pkgs.system}.default

    # ===== VERSION CONTROL =====
    git
    git-cliff
    delta # git-delta
    git-extras
    git-lfs
    gh # GitHub CLI
    stow

    # ===== SHELL & CLI TOOLS =====
    fish
    starship
    zoxide
    eza
    bat
    fd
    ripgrep
    fzf
    tree
    lsd
    moreutils

    # ===== SYSTEM UTILITIES =====
    coreutils
    curl
    wget
    htop
    btop
    tree-sitter
    tokei
    topgrade
    just
    jq
    yq-go
    lnav

    # ===== DEVELOPMENT TOOLS =====
    cmake
    gnumake
    ninja
    gcc
    llvm
    nodejs
    python3
    python313 # python@3.13
    ruby
    zig

    # ===== PYTHON TOOLS =====
    pipenv
    pipx
    uv

    # ===== CONTAINERS & VMs =====
    docker
    docker-compose
    podman

    # ===== DATABASES =====
    libpqxx # libpq
    pgcli

    # ===== SECURITY & CRYPTO =====
    gnupg
    mkcert
    yubikey-manager # ykman
    yubico-piv-tool
    openssl # for bcrypt functionality

    # ===== NETWORKING =====
    awscli2 # awscli

    # ===== MEDIA =====
    ffmpeg
    imagemagick
    exiftool
    poppler_utils
    zbar

    # ===== FILE MANAGERS & MULTIPLEXERS =====
    yazi
    zellij

    # ===== DATA FORMATS =====
    jsonnet

    # ===== BUILD TOOLS =====
    luarocks

    # ===== TERMINAL EMULATORS =====
    wezterm
    kitty

    # ===== BROWSERS & COMMUNICATION =====
    firefox
    whatsapp-for-linux

    # ===== DEVELOPMENT GUI =====
    zed-editor # zed

    # ===== MEDIA PLAYERS =====
    vlc
    mpv

    # ===== GRAPHICS & DIAGRAMS =====
    drawio

    # ===== UTILITIES =====
    _1password-gui # 1password
    _1password-cli # 1password-cli
    activitywatch
    libnotify

    # ===== COMPRESSION =====
    p7zip # sevenzip

    # ===== AI & LLM =====
    ollama

    # ===== SCIENTIFIC =====
    gnuplot
    graphviz

    # ===== TEXT PROCESSING =====
    lynx
    tesseract

    # ===== HYPRLAND ESSENTIALS =====
    blueberry
    brightnessctl
    clipse
    fastfetch
    grim
    hyprshot
    hyprsunset
    hyprlock
    hypridle
    networkmanagerapplet
    playerctl
    slurp
    wl-clipboard
    xdg-desktop-portal-hyprland

    # ===== WAYLAND/QT TOOLS =====
    qt5ct
    qt6ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    kdePackages.polkit-kde-agent-1
    quickshell
    awww.packages.${pkgs.system}.awww
    vicinae.packages.${pkgs.system}.default
  ];

  # Enable fonts
  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      fira-code
      fira-code-symbols
      font-awesome
      comic-neue
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
