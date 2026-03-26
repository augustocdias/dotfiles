{
  den,
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.sqlit = {
    url = lib.mkDefault "github:Maxteabag/sqlit";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.sqlit = {
    includes = [
      (den.lib.perHost {
        # Wrap sqlit with psycopg2 for PostgreSQL support
        nixos.nixpkgs.overlays = lib.optionals (inputs ? sqlit) [
          (_: prev: let
            sqlitPkg = inputs.sqlit.packages.${prev.stdenv.hostPlatform.system}.default;
          in {
            sqlit-with-postgres = prev.symlinkJoin {
              name = "sqlit-with-postgres";
              paths = [sqlitPkg];
              buildInputs = [prev.makeWrapper];
              postBuild = ''
                wrapProgram $out/bin/sqlit \
                  --prefix PYTHONPATH : "${prev.python3Packages.psycopg2}/${prev.python3.sitePackages}"
              '';
            };
          })
        ];
      })
    ];

    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.sqlit-with-postgres];
    };
  };
}
