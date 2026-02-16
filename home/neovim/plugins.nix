# Neovim plugins fetched from GitHub
# To update SHA256 hashes: Run update-nvim
{
  pkgs,
  lib,
  ...
}: let
  sources = builtins.fromJSON (builtins.readFile ./plugins.json);

  # Helper to construct binary download URL from plugin info
  # Note: Plugins with binary field must use a tag for rev
  mkBinaryUrl = plugin: "https://github.com/${plugin.owner}/${plugin.repo}/releases/download/${plugin.rev}/${plugin.binary.filename}";

  # Plugin SHA256 hashes
  # When adding a new plugin or updating, use lib.fakeSha256 first
  # Then run nixos-rebuild and copy the correct hash from the error message
  # Binary hashes use the format: plugin-name-binary
  shas = {
    auto-session = "1lnx5rgb68f0s57xm97hr585qyp3lpxvn3fxd7az40sdh7zh7fjm";
    blink-cmp = "1bzagack76cc78fa7l9hr63fx5sawxmzsdaqrxv82hm9smfis2hs";
    blink-cmp-binary = "1x7pvbddnk1yslczjnw0yik8wzr051fsaiax7bi5lng22d06dcjj";
    catppuccin = "1gcrv04b5gpjy0gzfgfwwiwl9jfl928qzwb6ji1hkhr8liil8k6j";
    codecompanion = "1mdn4q2c89pk2anr3490gfw4p9pxkiv81dgqrrsb8hb3w5jp63iw";
    codecompanion-history = "1s6qki0xrk936wm0rwwdsd67y0lqhw5nzjffassgw0dbgb4yjz2a";
    codecompanion-spinner = "05qhr9v9rkl9npv4xayjjn5phfzqa625vlr9mh05k47lbv4j4aa1";
    codesnap = "1bw634i34djxcncdnjlkx1icn7gmfbi0vg7mi70cyjd51sx0v6w2";
    codesnap-binary = "0n2snm2sb5b444g7il5v49h6wsrqvj5vm179m0h7k3pvcdxwjfsr";
    colorful-menu = "18y5mzjqs43hcf9n2mjzqq159lnyxyihw3b606nqmc4na90bpdl6";
    conform = "03ri7h47ff1fzh7p3ygm506m2q7zhhj1bj6cx281h092bws8cs9k";
    crates = "10hc28r9k4syay1pir24mk6kjj96llilqkyz8ch6rjmxyi7r5ycd";
    diffview = "0brabpd02596hg98bml118bx6z2sly98kf1cr2p0xzybiinb4zs9";
    dropbar = "0hibhh46g0gnc9av4xd0zfc6xgdwbajw0ib4m827k4zhqrjmfchp";
    flash = "1xm26117d95qcnx2hpi8g469awmsr8wwdg1bmvipgjkzjys78y54";
    gatekeeper = "18d85971ir1z93kdq0wa2hgfm3p51fq04n8kmwnk6c1wl0y2imd4";
    gitsigns = "0v2mzydpinpj1ids6b1wb17a3c7c7hp4z5nyv1b2hnhslfj7a0gi";
    gx = "14g19wr83vbclqwgg928bkygh31kmil7s505l952dzllipyy3ym1";
    helpview = "0i21sffzvf5gq0zghf60hkz7sbmd01w5q3maqz48f037zydivmsj";
    lightbulb = "0wp8f6yphb28iaxlhg326kvrh3h8xn5fkkcfn1whbacch6562wym";
    lualine = "1q34vy3rcwv4nz1b2n2hvp2yxs8clczzvyf3mpvcir8bxcgxk4is";
    lze = "0y6ad92wgrankw8hs26fvlmrbm3qyigz7xw7mk8y2axs3fc5j720";
    markdown-plus = "1qzfxhwk789gvwm42ndn88xaxxsg6h2nfi5874p9mxglpblkpngp";
    markview = "0awjpc9rzbl24n7br3vzr5zhayn5y0ayl6539pr7014v3amxc2k8";
    mcphub = "009w7iq31k9sx94p3izqnjbgi0gr9fwn7p5wjcaa3kz16jz4znw3";
    mini-ai = "1ic1x1117yyswid51a3l1857wxhdf7aq3jl0mdwwx1xdlzlrn60j";
    mini-files = "0qxmvjnhsald2pa9535g0han7alwcj5w3kczkj444pljljpxn437";
    mini-icons = "1q98s0jgarp6d8ac5cx0z9y9hmmcas982rsa3kkwr6mnkjdq2zc0";
    mini-move = "0hm9adfn4p3s4i97vqgpkbki6wz3r0g22l5mjyy0ffz8qdrdjvv5";
    noice = "02mc75dqn7h4ylgynpd9vsjx3y51rcys95l9ax1wiilgb4ay3b0l";
    nui = "0l1ga86dr2rhfjshiicsw3nn03wrhmdqks8v1gn3xmzdgfd2anz3";
    nvim-autopairs = "19czzkgz7kdvhrg1hh472xymsh97v0rnll1gx9rsbkl22akrg2nh";
    nvim-dap = "15y2ib360mz9h7ypzp3324l35qlm2k52wrcx8q8qmchya473z9kw";
    nvim-dap-ui = "04378nxmh37dys2zbpwqs0wp82yr8racpmy7r44y1snx30577pfz";
    nvim-dap-virtual-text = "1xg16c3ncs6nrd1gxdrysa1m123vzp17bx0n6v183gi79kw286zj";
    nvim-lint = "19xjgl0932avqi8bdx442jl7is1nq0z2dl8q7bzl22in5kbmaasm";
    nvim-lspconfig = "1ygzfr76mscj7l61aaazbz2svxkfyb8bcsj50v4lqrsj85qrl8mz";
    nvim-nio = "1bz5msxwk232zkkhfxcmr7a665la8pgkdx70q99ihl4x04jg6dkq";
    nvim-notify = "1qsxv5w8pb4pv0963lwhsy21cgi75mw2a0s20vm1821y6qr97d47";
    nvim-surround = "15ynh9rfhvg46z1a7aynpmm5nh01ydyhhryf39v0w4qyclypsci3";
    nvim-treesitter-context = "0dmcpn7l1f4bxvfa4li9sw8k1a5gh0r9zslflb5yrnax1ww71nyw";
    nvim-treesitter-textobjects = "0h3n73n12k4sqzdnhls480iyx92vvsxhyhg1d5wac9m5nsfzww17";
    octo = "1kg7b5blk860jm1kc7gqmkh31hld32l0biw7901vwhb3ygy1514l";
    plenary = "1kg043h7dqcrqqgg8pp6hsldx7jdhlh8qwad2kkckia191xgnjgm";
    refactoring = "1wl2167fly4r3yzpkhl0qlprcn1p4n6p6cg6g1dy3sas8mzzan98";
    rustaceanvim = "0mwrspy7qygnik10b1z3hckr654ml98766g374hfckhvxhcppqiq";
    SchemaStore = "1qz6g4p735bvqx99177rrf4m9plbm0rws5bs014qbkh8v9zpz1pn";
    snacks = "18x8m1fhq9kjch1jmzax3nd0h8j5kgd5ykj8bg366h5x1mi9s5xx";
    tabby = "1vaaiypq9c9rzjhsn31ddihyjqbcdyvy383vpsis4bjjbbyg02b0";
    tabout = "1mjnzrz2zh8kd95p12l70zmpw7nf5xnlr4pwss51s2cgy1wyfgz5";
    todo-comments = "091893pjvhs1qwcnd6ksa5mngzr0n9z9lkyg7c97ic0hzi2qhrsl";
    tokyonight = "1s8qh9a8yajlfybcsky6rb31f0ihfhapm51531zn4xd0fyzy8dz3";
    trouble = "0cpwraxfvhnw0lvq26w58s15ynzyah9xn26bqn41acyi7ddclkz9";
    typescript-tools = "0h4v876rfgliynwshpbv2mdrxmimymr07z0j31ggdv9b8p0n5kh8";
    undotree = "1wdip0ydb04in60x49zy9lkg364y743gm4qhlz04p22kqbgx7pq5";
    vim-matchup = "15mka79mrs0lqrhmzwiqfh4npr3pjnpbb206rqvqb7yrw3g2jxkz";
    which-key = "1dwri7gxqgb58pfy829s0ns709m0nrcj1cgz2wj1k09qfffri9mc";
  };

  # Helper to build a vim plugin from source
  buildPlugin = name: plugin: let
    # Fetch binary if plugin has binary field
    binaryDrv =
      if plugin ? binary
      then
        pkgs.fetchurl {
          url = mkBinaryUrl plugin;
          sha256 = shas."${name}-binary" or lib.fakeSha256;
        }
      else null;

    basePlugin = pkgs.vimUtils.buildVimPlugin {
      pname = name;
      version = plugin.rev or "latest";
      src = pkgs.fetchFromGitHub {
        owner = plugin.owner;
        repo = plugin.repo;
        rev = plugin.rev or "HEAD";
        sha256 = shas.${name};
      };
      # Disable require checks for all plugins
      # Many plugins have optional dependencies that fail the check
      doCheck = false;
    };
  in
    # Apply build configuration or binary installation if needed
    if plugin ? binary
    then
      basePlugin.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            mkdir -p $out/${builtins.dirOf plugin.binary.destPath}
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
  # Build all plugins
  plugins = lib.mapAttrs buildPlugin sources;

  # Export as list for programs.neovim.plugins
  # Wrapped with optional based on lazy field (defaults to true)
  pluginList =
    lib.mapAttrsToList (name: plugin: {
      plugin = buildPlugin name plugin;
      optional = plugin.lazy or true;
    })
    sources;

  inherit sources shas;
}
