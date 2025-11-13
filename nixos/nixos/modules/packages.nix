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

    # ===== LSP SERVERS =====
    emmylua-ls # Lua LSP
    yaml-language-server
    vscode-langservers-extracted # jsonls, eslint, html, css
    taplo # TOML LSP
    dockerfile-language-server
    docker-compose-language-service
    bash-language-server
    nodePackages.typescript-language-server
    harper # Grammar checker LSP
    nil # Nix LSP
    qt6.qtdeclarative # qmlls for Quickshell

    # ===== FORMATTERS =====
    black # Python
    nodePackages.prettier
    markdownlint-cli
    shfmt # Shell
    stylua # Lua
    sqlfluff # SQL
    alejandra # Nix formatter (recommended)

    # ===== LINTERS =====
    codespell
    selene # Lua
    nodePackages.write-good
    yamllint
    hadolint # Dockerfile
    actionlint # GitHub Actions
    statix # Nix linter
    deadnix # Nix dead code detection

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

    # ===== RUST TOOLCHAIN =====
    cargo
    rustc
    clippy
    rustfmt
    rust-analyzer

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
    pinentry-curses # Terminal-based pinentry for GPG
    mkcert
    yubikey-manager # ykman
    yubikey-personalization # Yubikey configuration tools
    yubico-piv-tool
    openssl # for bcrypt functionality
    tpm2-tools # TPM2 management for LUKS auto-unlock
    libfido2 # FIDO2 support for LUKS
    cryptsetup # LUKS disk encryption

    # ===== NETWORKING =====
    awscli2 # awscli

    # ===== MEDIA =====
    ffmpeg
    imagemagick
    exiftool
    poppler-utils
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
    wasistlos

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
    claude-code

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

    # ===== WAYLAND/QT TOOLS =====
    libsForQt5.qt5ct
    kdePackages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    kdePackages.polkit-kde-agent-1
    quickshell
    awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Enable fonts
  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      fira-code
      fira-code-symbols
      font-awesome
      comic-neue
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
