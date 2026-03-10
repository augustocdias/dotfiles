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

    pass-secret-service = let
      version = "0.6.0";
      src = fetchGit {
        url = "https://github.com/grimsteel/pass-secret-service.git";
        ref = "refs/tags/v${version}";
        rev = "b033a419b2fe644df5f8fa9de0a514398eb8428b";
      };
      binary = prev.fetchurl {
        url = "https://github.com/grimsteel/pass-secret-service/releases/download/v${version}/pass-secret-service-x86_64";
        hash = "sha256-A39wgVsLZ4i5bkZzxyFPDnmnvpveR2v9scjytOkD2cI=";
      };
    in
      prev.stdenv.mkDerivation {
        pname = "pass-secret-service";
        inherit version;

        dontUnpack = true;

        nativeBuildInputs = [prev.autoPatchelfHook prev.makeWrapper];
        buildInputs = [prev.stdenv.cc.cc.lib];

        installPhase = ''
          runHook preInstall

          install -Dm755 ${binary} $out/bin/.pass-secret-service-unwrapped
          wrapProgram $out/bin/.pass-secret-service-unwrapped \
            --prefix PATH : "${prev.gnupg}/bin"
          mv $out/bin/.pass-secret-service-unwrapped $out/bin/pass-secret-service

          # Compat symlink: home-manager module expects pass_secret_service (underscore)
          ln -s $out/bin/pass-secret-service $out/bin/pass_secret_service

          # D-Bus activation file from source
          install -Dm644 ${src}/systemd/org.freedesktop.secrets.service \
            $out/share/dbus-1/services/org.freedesktop.secrets.service
          substituteInPlace $out/share/dbus-1/services/org.freedesktop.secrets.service \
            --replace-warn "/usr/bin/pass-secret-service" "$out/bin/pass-secret-service"

          runHook postInstall
        '';

        meta = with prev.lib; {
          description = "Implementation of org.freedesktop.secrets using pass";
          homepage = "https://github.com/grimsteel/pass-secret-service";
          license = licenses.gpl3Only;
          mainProgram = "pass-secret-service";
          platforms = ["x86_64-linux"];
        };
      };
  })
  (_: prev: {
    wasistlos-no-mpris = let
      wasistlos = prev.wasistlos;
      xdg-dbus-proxy = prev.xdg-dbus-proxy;
      wrapper = prev.writeShellScript "wasistlos-dbus-filtered" ''
        PROXY_SOCKET="''${XDG_RUNTIME_DIR}/wasistlos-dbus-proxy-$$"

        cleanup() {
          kill "$PROXY_PID" 2>/dev/null
          rm -f "$PROXY_SOCKET"
        }
        trap cleanup EXIT

        ${xdg-dbus-proxy}/bin/xdg-dbus-proxy \
          "$DBUS_SESSION_BUS_ADDRESS" \
          "$PROXY_SOCKET" \
          --filter \
          --sloppy-names \
          --own=com.github.xeco23.WasIstLos \
          --talk=org.freedesktop.DBus \
          --talk=org.freedesktop.Notifications \
          --talk="org.freedesktop.portal.*" \
          --talk=org.freedesktop.ScreenSaver \
          --talk=org.freedesktop.secrets \
          --talk=ca.desrt.dconf \
          --talk=org.kde.StatusNotifierWatcher \
          --talk="org.gtk.vfs.*" \
          --talk=org.a11y.Bus \
          --talk=org.gtk.GLib.PACRunner \
          --talk="org.mozilla.firefox.*" \
          --broadcast="org.freedesktop.portal.*=@/org/freedesktop/portal/*" &

        PROXY_PID=$!

        # Wait for proxy socket to appear
        for _i in $(seq 1 50); do
          [ -S "$PROXY_SOCKET" ] && break
          sleep 0.1
        done

        if [ ! -S "$PROXY_SOCKET" ]; then
          echo "wasistlos-dbus-proxy: proxy socket failed to appear, falling back to unfiltered" >&2
          exec ${wasistlos}/bin/wasistlos "$@"
        fi

        DBUS_SESSION_BUS_ADDRESS="unix:path=$PROXY_SOCKET" \
          exec ${wasistlos}/bin/wasistlos "$@"
      '';
    in
      prev.symlinkJoin {
        name = "wasistlos-no-mpris";
        paths = [wasistlos];
        nativeBuildInputs = [prev.makeWrapper];
        postBuild = ''
          rm "$out/bin/wasistlos"
          makeWrapper ${wrapper} "$out/bin/wasistlos"
        '';
        meta = wasistlos.meta // {
          description = "WasIstLos with MPRIS D-Bus registration blocked";
        };
      };
  })
]
