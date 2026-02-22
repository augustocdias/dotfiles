# Fetch plugins from their repos for newer releases
# To update plugin revisions: Run update-nvim
{
  pkgs,
  lib,
  ...
}: let
  sources = builtins.fromJSON (builtins.readFile ./plugins.json);

  # Note: Plugins with binary field must use a tag for rev
  # Note: Binary URL pattern assumes GitHub releases; custom remotes may need different handling
  mkBinaryUrl = plugin: "${plugin.remote or "https://github.com"}/${plugin.owner}/${plugin.repo}/releases/download/${plugin.rev}/${plugin.binary.filename}";

  # This block is updated by the script
  revs = {
    auto-session = "62437532b38495551410b3f377bcf4aaac574ebe";
    blink-cmp = "4b18c32adef2898f95cdef6192cbd5796c1a332d";
    catppuccin = "0a5de4da015a175f416d6ef1eda84661623e0500";
    codecompanion = "558518f8d78a44198cd428f6bf8bf48bfa38d76d";
    codecompanion-history = "bc1b4fe06eaaf0aa2399be742e843c22f7f1652a";
    codecompanion-spinner = "7797a81141e5de62eecebf2af561698ed58900dc";
    codesnap = "bd5668f13da97e0f0639131de2ef056b0560f2cc";
    colorful-menu = "b51a659459df8d078201aefc995db8175ed55e84";
    conform = "c2526f1cde528a66e086ab1668e996d162c75f4f";
    crates = "ac9fa498a9edb96dc3056724ff69d5f40b898453";
    diffview = "4516612fe98ff56ae0415a259ff6361a89419b0a";
    dropbar = "ce202248134e3949aac375fd66c28e5207785b10";
    flash = "fcea7ff883235d9024dc41e638f164a450c14ca2";
    gatekeeper = "c38254f293c147949df009db29f6899815aef653";
    gitsigns = "9f3c6dd7868bcc116e9c1c1929ce063b978fa519";
    gx = "ba9c408fc0130fc4548760c3933a81b58fc50de8";
    helpview = "518789535a0cb146224a428edf93a70f98b795db";
    lightbulb = "aa3a8b0f4305b25cfe368f6c9be9923a7c9d0805";
    lualine = "47f91c416daef12db467145e16bed5bbfe00add8";
    lze = "7276233f8fbe883e0a3b2164a836a2b292883a1c";
    markdown-plus = "438ea474f8f12993244c195b883dc1924a709086";
    markview = "633e627f82011dc888ea4444a98c98bd783951b0";
    mcphub = "7cd5db330f41b7bae02b2d6202218a061c3ebc1f";
    mini-ai = "4b0a6207341d895b6cfe9bcb1e4d3e8607bfe4f4";
    mini-files = "1202e26484c10e9d6190cab3314dd187f871472c";
    mini-icons = "5b9076dae1bfbe47ba4a14bc8b967cde0ab5d77e";
    mini-move = "b8ba0b77e91b5f0fe8e014e03f7f59799dec1d96";
    noice = "7bfd942445fb63089b59f97ca487d605e715f155";
    nui = "de740991c12411b663994b2860f1a4fd0937c130";
    nvim-autopairs = "59bce2eef357189c3305e25bc6dd2d138c1683f5";
    nvim-dap = "db321947bb289a2d4d76a32e76e4d2bd6103d7df";
    nvim-dap-ui = "cf91d5e2d07c72903d052f5207511bf7ecdb7122";
    nvim-dap-virtual-text = "fbdb48c2ed45f4a8293d0d483f7730d24467ccb6";
    nvim-lint = "486474c2ace8d78d28995074dbdbe29011bc63d0";
    nvim-lspconfig = "5a855bcfec7973767a1a472335684bbd71d2fa2b";
    nvim-nio = "21f5324bfac14e22ba26553caf69ec76ae8a7662";
    nvim-notify = "8701bece920b38ea289b457f902e2ad184131a5d";
    nvim-surround = "1098d7b3c34adcfa7feb3289ee434529abd4afd1";
    nvim-treesitter-context = "64dd4cf3f6fd0ab17622c5ce15c91fc539c3f24a";
    nvim-treesitter-textobjects = "a0e182ae21fda68c59d1f36c9ed45600aef50311";
    octo = "5ae580df72589f25b775ff2bdacfd7f7be8d63bd";
    plenary = "b9fd5226c2f76c951fc8ed5923d85e4de065e509";
    refactoring = "6784b54587e6d8a6b9ea199318512170ffb9e418";
    rustaceanvim = "f85cfdbdb083ec734eb3f3d79d588dece6f2c82d";
    SchemaStore = "84d86aa49021aa8b48c0a6ff89cd92c39ddf7d5c";
    snacks = "fe7cfe9800a182274d0f868a74b7263b8c0c020b";
    tabby = "3c130e1fcb598ce39a9c292847e32d7c3987cf11";
    tabout = "9a3499480a8e53dcaa665e2836f287e3b7764009";
    todo-comments = "31e3c38ce9b29781e4422fc0322eb0a21f4e8668";
    tokyonight = "5da1b76e64daf4c5d410f06bcb6b9cb640da7dfd";
    trouble = "bd67efe408d4816e25e8491cc5ad4088e708a69a";
    typescript-tools = "c2f5910074103705661e9651aa841e0d7eea9932";
    undotree = "f68aed28c8ff1294b012dfadaced2084dc045870";
    vim-matchup = "0fb1e6b7cea34e931a2af50b8ad565c5c4fd8f4d";
    which-key = "3aab2147e74890957785941f0c1ad87d0a44c15a";
  };

  # SHA256 hashes for binary downloads only
  binaryShas = {
    blink-cmp = "1x7pvbddnk1yslczjnw0yik8wzr051fsaiax7bi5lng22d06dcjj";
    codesnap = "0n2snm2sb5b444g7il5v49h6wsrqvj5vm179m0h7k3pvcdxwjfsr";
  };

  buildPlugin = name: plugin: let
    binaryDrv =
      if plugin ? binary
      then
        pkgs.fetchurl {
          url = mkBinaryUrl plugin;
          sha256 = binaryShas.${name} or lib.fakeSha256;
        }
      else null;

    basePlugin = pkgs.vimUtils.buildVimPlugin {
      pname = name;
      version = plugin.rev or "latest";
      src = builtins.fetchGit {
        url = "${plugin.remote or "https://github.com"}/${plugin.owner}/${plugin.repo}";
        rev = revs.${name};
      };
      doCheck = false;
    };
  in
    if plugin ? binary
    then
      basePlugin.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            mkdir -p $out/${dirOf plugin.binary.destPath}
            cp ${binaryDrv} $out/${plugin.binary.destPath}
            chmod +x $out/${plugin.binary.destPath}
          ''
          + (
            if plugin.binary ? versionFile
            then ''
              echo "${plugin.binary.versionFile.content}" > $out/${plugin.binary.versionFile.path}
            ''
            else ""
          );
      })
    else if plugin ? buildInputs || plugin ? buildPhase || plugin ? postBuild || plugin ? postInstall
    then
      basePlugin.overrideAttrs (oldAttrs: {
        nativeBuildInputs =
          (oldAttrs.nativeBuildInputs or [])
          ++ (map (input: pkgs.${input}) (plugin.buildInputs or []));
        buildPhase = plugin.buildPhase or oldAttrs.buildPhase or "";
        postBuild = plugin.postBuild or oldAttrs.postBuild or "";
        postInstall = plugin.postInstall or oldAttrs.postInstall or "";
      })
    else basePlugin;
in {
  plugins = lib.mapAttrs buildPlugin sources;

  pluginList =
    lib.mapAttrsToList (name: plugin: {
      plugin = buildPlugin name plugin;
      optional = plugin.lazy or true;
    })
    sources;

  inherit sources revs binaryShas;
}
