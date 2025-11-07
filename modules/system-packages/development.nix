# System-wide development tools
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
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
    git
    git-lfs

    # Development environment tools
    direnv

    # Container tools
    docker
    docker-compose
  ];
}
