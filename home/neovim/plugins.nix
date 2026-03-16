# Neovim plugins built from flake inputs
# To update plugin revisions: nix flake update --flake ~/nixos/home/neovim
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  pluginInputs = inputs.neovim-plugins.inputs;

  # Plugins with useFlakePackage use the flake's pre-built package output
  # Plugins with buildFromSource need custom build logic
  # All others are built with buildVimPlugin from their flake input source
  pluginMeta = {
    lze = {
      lazy = false;
      useFlakePackage = true;
    };
    blink-cmp = {useFlakePackage = true;};
    rustaceanvim = {useFlakePackage = true;};
    gx = {};
    codesnap = {buildFromSource = true;};
    plenary = {};
    nui = {};
    nvim-lspconfig = {};
    SchemaStore = {};
    nvim-treesitter-textobjects = {};
    nvim-treesitter-context = {};
    catppuccin = {};
    tokyonight = {};
    lualine = {};
    which-key = {};
    noice = {};
    nvim-notify = {};
    tabby = {};
    dropbar = {};
    auto-session = {};
    snacks = {};
    helpview = {};
    tabout = {};
    colorful-menu = {};
    gitsigns = {};
    diffview = {};
    octo = {};
    flash = {};
    trouble = {};
    todo-comments = {};
    nvim-autopairs = {};
    vim-matchup = {};
    mini-icons = {};
    mini-ai = {};
    mini-files = {};
    mini-move = {};
    mini-surround = {};
    conform = {};
    nvim-lint = {};
    lightbulb = {};
    nvim-dap = {};
    nvim-dap-ui = {};
    nvim-dap-virtual-text = {};
    typescript-tools = {};
    undotree = {};
    markview = {};
    codecompanion = {};
    gatekeeper = {};
    codecompanion-spinner = {};
    nvim-nio = {};
    codecompanion-history = {};
    mcphub = {};
    crates = {};
    refactoring = {};
    markdown-plus = {};
  };

  # Build codesnap's Rust generator library from source
  codesnap-generator = pkgs.rustPlatform.buildRustPackage {
    pname = "codesnap-generator";
    version = "unstable";
    src = pluginInputs.codesnap;
    sourceRoot = "source/generator";
    cargoLock = {
      lockFile = "${pluginInputs.codesnap}/generator/Cargo.lock";
    };
    nativeBuildInputs = with pkgs; [pkg-config];
    buildInputs = with pkgs; [openssl];
    # codesnap's Cargo.toml uses openssl vendored feature, but we provide system openssl
    # Override the vendored feature to use system openssl instead
    OPENSSL_NO_VENDOR = 1;
    doCheck = false;
  };

  buildPlugin = name: meta: let
    src = pluginInputs.${name};
  in
    if meta ? useFlakePackage
    then pluginInputs.${name}.packages.${system}.default
    else if meta ? buildFromSource && name == "codesnap"
    then
      pkgs.vimUtils.buildVimPlugin {
        pname = name;
        version = "flake";
        inherit src;
        doCheck = false;
        postInstall = ''
          ln -s ${codesnap-generator}/lib/libgenerator.so $out/lua/generator.so
        '';
      }
    else
      pkgs.vimUtils.buildVimPlugin {
        pname = name;
        version = "flake";
        inherit src;
        doCheck = false;
      };
in {
  plugins = lib.mapAttrs buildPlugin pluginMeta;

  pluginList =
    lib.mapAttrsToList (name: meta: {
      plugin = buildPlugin name meta;
      optional = meta.lazy or true;
    })
    pluginMeta;

  inherit pluginMeta;
}
