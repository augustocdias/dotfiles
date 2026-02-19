inputs: [
  inputs.neovim-nightly-overlay.overlays.default
  (final: prev: {
    sqlit-with-postgres = let
      sqlitPkg = inputs.sqlit.packages.${prev.stdenv.hostPlatform.system}.default;
    in
      prev.symlinkJoin {
        name = "sqlit-with-postgres";
        paths = [sqlitPkg];
        buildInputs = [prev.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/sqlit \
            --prefix PYTHONPATH : "${prev.python3Packages.psycopg2}/${prev.python3.sitePackages}"
        '';
      };
  })
  (final: prev: let
    version = "3.3.0";
    assets = {
      "aarch64-linux" = {
        target = "aarch64-unknown-linux-gnu";
        sha256 = "32f774341105a6a2b30a1204b617db0e4e170a81cd127ac12f2d098efda9a412";
      };
      "x86_64-linux" = {
        target = "x86_64-unknown-linux-gnu";
        sha256 = "853bf0f8e6fbdad72ff397347003ad735f51d85d5c14ce6f8873a0b2247a4285";
      };
    };
    asset = assets.${prev.stdenv.hostPlatform.system};
  in {
    skim = prev.stdenv.mkDerivation {
      pname = "skim";
      inherit version;

      src = prev.fetchurl {
        url = "https://github.com/skim-rs/skim/releases/download/v${version}/skim-${asset.target}.tar.xz";
        sha256 = asset.sha256;
      };

      sourceRoot = "skim-${asset.target}";

      nativeBuildInputs = [prev.autoPatchelfHook];
      buildInputs = [prev.stdenv.cc.cc.lib];

      installPhase = ''
        mkdir -p $out/bin $out/share/skim $out/share/man/man1
        cp sk $out/bin/
        cp shell/* $out/share/skim/
        cp man/man1/* $out/share/man/man1/
      '';

      meta = with prev.lib; {
        description = "Fuzzy Finder in Rust";
        homepage = "https://github.com/skim-rs/skim";
        license = licenses.mit;
        platforms = builtins.attrNames assets;
      };
    };
  })
]
