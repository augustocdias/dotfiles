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
    catppuccin = "12c004cde3f36cb1d57242f1e6aac46b09a0e5b4";
    codecompanion = "5e4f7cfac58c94c61d5a3d3a99d715d5c8762db6";
    codecompanion-history = "bc1b4fe06eaaf0aa2399be742e843c22f7f1652a";
    codecompanion-spinner = "7797a81141e5de62eecebf2af561698ed58900dc";
    codesnap = "0a0941340376439a25d6cd8a4d1d2b372edbfdbd";
    colorful-menu = "b51a659459df8d078201aefc995db8175ed55e84";
    conform = "086a40dc7ed8242c03be9f47fbcee68699cc2395";
    crates = "ac9fa498a9edb96dc3056724ff69d5f40b898453";
    diffview = "4516612fe98ff56ae0415a259ff6361a89419b0a";
    dropbar = "ce202248134e3949aac375fd66c28e5207785b10";
    flash = "fcea7ff883235d9024dc41e638f164a450c14ca2";
    gatekeeper = "c38254f293c147949df009db29f6899815aef653";
    gitsigns = "7c4faa3540d0781a28588cafbd4dd187a28ac6e3";
    gx = "ba9c408fc0130fc4548760c3933a81b58fc50de8";
    helpview = "518789535a0cb146224a428edf93a70f98b795db";
    lightbulb = "aa3a8b0f4305b25cfe368f6c9be9923a7c9d0805";
    lualine = "47f91c416daef12db467145e16bed5bbfe00add8";
    lze = "a3ba1a2d469d4ab26acb629aba8c7d70a6cbe558";
    markdown-plus = "6ddbb55f1e8be011cdae7f20910034fcd52e8be3";
    markview = "239feb70ed1cfc26e2c91b32590fd63f7b015599";
    mcphub = "7cd5db330f41b7bae02b2d6202218a061c3ebc1f";
    mini-ai = "4b0a6207341d895b6cfe9bcb1e4d3e8607bfe4f4";
    mini-files = "57eb96a828f80efb8095a611e3aafcfa43548f8b";
    mini-icons = "5b9076dae1bfbe47ba4a14bc8b967cde0ab5d77e";
    mini-move = "b8ba0b77e91b5f0fe8e014e03f7f59799dec1d96";
    mini-surround = "d205d1741d1fcc1f3117b4e839bf00f74ad72fa2";
    noice = "7bfd942445fb63089b59f97ca487d605e715f155";
    nui = "de740991c12411b663994b2860f1a4fd0937c130";
    nvim-autopairs = "59bce2eef357189c3305e25bc6dd2d138c1683f5";
    nvim-dap = "a9d8cb68ee7184111dc66156c4a2ebabfbe01bc5";
    nvim-dap-ui = "cf91d5e2d07c72903d052f5207511bf7ecdb7122";
    nvim-dap-virtual-text = "fbdb48c2ed45f4a8293d0d483f7730d24467ccb6";
    nvim-lint = "606b823a57b027502a9ae00978ebf4f5d5158098";
    nvim-lspconfig = "d8bf4c47385340ab2029402201d4d7c9f99f437a";
    nvim-nio = "21f5324bfac14e22ba26553caf69ec76ae8a7662";
    nvim-notify = "8701bece920b38ea289b457f902e2ad184131a5d";
    nvim-treesitter-context = "529ee357b8c03d76ff71233afed68fd0f5fe10b1";
    nvim-treesitter-textobjects = "4e91b5d0394329a229725b021a8ea217099826ef";
    octo = "42e547c08433c22c8311d7848998d2d08bfaf77e";
    plenary = "b9fd5226c2f76c951fc8ed5923d85e4de065e509";
    refactoring = "6784b54587e6d8a6b9ea199318512170ffb9e418";
    rustaceanvim = "f2f0c1231a5b019dbc1fd6dafac1751c878925a3";
    SchemaStore = "47b1e85c020c9c359a2e6438405dd7b382b014af";
    snacks = "9912042fc8bca2209105526ac7534e9a0c2071b2";
    tabby = "3c130e1fcb598ce39a9c292847e32d7c3987cf11";
    tabout = "9a3499480a8e53dcaa665e2836f287e3b7764009";
    todo-comments = "31e3c38ce9b29781e4422fc0322eb0a21f4e8668";
    tokyonight = "5da1b76e64daf4c5d410f06bcb6b9cb640da7dfd";
    trouble = "bd67efe408d4816e25e8491cc5ad4088e708a69a";
    typescript-tools = "c2f5910074103705661e9651aa841e0d7eea9932";
    undotree = "0e6d41d55ad147407e4ba00a292973de8db0b836";
    vim-matchup = "0fb1e6b7cea34e931a2af50b8ad565c5c4fd8f4d";
    which-key = "3aab2147e74890957785941f0c1ad87d0a44c15a";
  };

  # SHA256 hashes for binary downloads only
  binaryShas = {
    blink-cmp = "15jrb4zh14hsjgm2lvniw8va7v6jg2aphgghip356chx4nw8z52m";
    codesnap = "0qndg38hhah5924v4xx8qikrihfibyp7aaw4h9ix9bldr49vpb3n";
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
