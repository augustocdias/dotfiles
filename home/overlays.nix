inputs: [
  inputs.neovim-nightly-overlay.overlays.default
  (_: prev: {
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
]
