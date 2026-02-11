{
  pkgs,
  config,
  inputs,
  ...
}: {
  # Enable pass-secret-service for secret storage (used by sqlit)
  services.pass-secret-service.enable = true;

  # Configure password-store with GPG key
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      PASSWORD_STORE_KEY = "7D8396F74725A208D835CE3730E62A1E4F078650";
    };
  };

  # Initialize pass store if it doesn't exist
  home.activation.initPasswordStore = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "${config.home.homeDirectory}/.password-store" ]; then
      ${pkgs.pass}/bin/pass init "7D8396F74725A208D835CE3730E62A1E4F078650"
    fi
  '';

  home.packages = with pkgs; [
    inputs.mcp-hub.packages.${pkgs.stdenv.hostPlatform.system}.default
    sqlit-with-postgres
    libsecret # For keyring CLI access

    # Compilers and build tools
    cmake
    gnumake
    ninja
    gcc
    llvm

    # Programming languages
    nodejs
    python3
    ruby

    # Rust toolchain
    cargo
    rustc
    cargo-expand
    cargo-nextest
    cargo-xwin

    # Version control
    git-lfs
    git-cliff
    git-extras
    gh

    # Development environment
    direnv
    pipenv
    just

    # Data processing
    jq
    yq-go
    jsonnet
    lnav

    tree-sitter

    awscli2
  ];
}
