{
  pkgs,
  lib,
  ...
}: let
  lotion = let
    version = "1.5.0";
    src = pkgs.fetchzip {
      url = "https://github.com/puneetsl/lotion/releases/download/v${version}/Lotion-linux-x64-${version}.zip";
      hash = "sha256-DZARH+bR5Rt/2esu9Cf/fHoxPl9xy4BXD1Vcwo3UIwM=";
    };
    icon = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/puneetsl/lotion/v${version}/assets/icon.png";
      hash = "sha256-McunOHmtDd3LR9fs4I4JSYkpvJp8nb3gayL7enPOMLU=";
    };
    # WORKAROUND: Patch to allow SSO/OAuth login flows inside the app.
    # Lotion blocks all non-Notion navigations in will-navigate, which breaks SSO
    # since the IdP redirect (e.g. Google, Okta) gets sent to the external browser.
    # Remove once fixed upstream: https://github.com/puneetsl/lotion/issues/145
    ssoFixPatch = pkgs.writeText "lotion-sso-fix.js" ''
      // Allow all in-tab navigations (needed for SSO/OAuth login flows).
      // External links via window.open() are still handled by setWindowOpenHandler above.
      webContents.on('will-navigate', (event, navigationUrl) => {
        log.debug("Tab " + this.tabId + ": Navigating to " + navigationUrl);
      });
    '';

    # Patch to enforce single instance and handle notion:// URLs by opening a new tab.
    # Without this, clicking notion:// links spawns a new Lotion process each time.
    singleInstancePatch = pkgs.writeText "lotion-single-instance.js" ''
      // --- Single instance lock & notion:// URL handling ---
      function notionUrlToHttps(url) {
        if (url && url.startsWith('notion://')) {
          return url.replace('notion://', 'https://');
        }
        return null;
      }

      function getNotionUrlFromArgs(args) {
        for (const arg of args) {
          const url = notionUrlToHttps(arg);
          if (url) return url;
        }
        return null;
      }

      function openNotionUrlInNewTab(url) {
        const appCtrl = AppController.getInstance();
        if (!appCtrl) return;
        const wc = appCtrl.getFocusedWindowController()
          || appCtrl.windowControllers.values().next().value;
        if (!wc) return;
        const bw = wc.getInternalBrowserWindow();
        if (bw) {
          if (bw.isMinimized()) bw.restore();
          bw.focus();
        }
        const TabManager = require('./managers/TabManager');
        const tabManager = TabManager.getInstance();
        const tabController = tabManager.createTab({
          windowId: wc.windowId,
          url: url,
          title: 'Loading...',
          makeActive: true,
        });
        wc.setActiveTab(tabController);
      }

      const gotTheLock = app.requestSingleInstanceLock();
      if (!gotTheLock) {
        app.quit();
      } else {
        app.on('second-instance', (event, commandLine) => {
          const url = getNotionUrlFromArgs(commandLine);
          if (url) {
            openNotionUrlInNewTab(url);
          } else {
            // Just focus the existing window
            const appCtrl = AppController.getInstance();
            if (appCtrl) {
              const wc = appCtrl.getFocusedWindowController()
                || appCtrl.windowControllers.values().next().value;
              if (wc) {
                const bw = wc.getInternalBrowserWindow();
                if (bw) {
                  if (bw.isMinimized()) bw.restore();
                  bw.focus();
                }
              }
            }
          }
        });
      }
    '';

    # Patch to handle notion:// URL on initial launch (open in new tab after window is ready).
    initialUrlPatch = pkgs.writeText "lotion-initial-url.js" ''
      // Handle notion:// URL passed on initial launch
      app.whenReady().then(() => {
        const initialUrl = getNotionUrlFromArgs(process.argv);
        if (initialUrl) {
          setTimeout(() => { openNotionUrlInNewTab(initialUrl); }, 1500);
        }
      });
    '';
    rpath = lib.makeLibraryPath (with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libdrm
      libnotify
      libpulseaudio
      libxkbcommon
      libgbm
      nspr
      nss
      pango
      pipewire
      stdenv.cc.cc
      systemd
      wayland
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
    ]);
  in
    pkgs.stdenv.mkDerivation {
      pname = "lotion";
      inherit version src;

      nativeBuildInputs = with pkgs; [makeWrapper asar];
      buildInputs = [pkgs.gtk3];

      dontBuild = true;
      dontPatchELF = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/lotion
        cp -r . $out/lib/lotion/
        chmod -R u+rwX $out/lib/lotion

        # Patch app.asar (see patch definitions above for details)
        local asar_dir=$(mktemp -d)
        asar extract $out/lib/lotion/resources/app.asar "$asar_dir"

        # 1. Fix SSO login in TabController.js
        local tc="$asar_dir/src/main/controllers/TabController.js"
        sed -i '/\/\/ Allow navigation within Notion, block external sites/,/^    });/d' "$tc"
        sed -i '/\/\/ Handle crashes/i LOTION_SSO_FIX_PLACEHOLDER' "$tc"
        sed -i -e "/LOTION_SSO_FIX_PLACEHOLDER/{r ${ssoFixPatch}" -e 'd}' "$tc"

        # 2. Add single-instance lock + notion:// URL handler in index.js
        local idx="$asar_dir/src/main/index.js"
        local tmp_idx=$(mktemp)
        awk -v patch="$(cat ${singleInstancePatch})" \
          '/\/\/ Instantiate AppController/ { print patch } { print }' \
          "$idx" > "$tmp_idx"
        cat ${initialUrlPatch} >> "$tmp_idx"
        mv "$tmp_idx" "$idx"

        asar pack "$asar_dir" $out/lib/lotion/resources/app.asar
        rm -rf "$asar_dir"

        # Patch all ELF binaries and shared libraries
        for file in $(find $out/lib/lotion -type f \( -name lotion -o -name chrome_crashpad_handler -o -name chrome-sandbox -o -name \*.so\* \)); do
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" 2>/dev/null || true
          patchelf --set-rpath "${rpath}:$out/lib/lotion" "$file" 2>/dev/null || true
        done
        chmod +x $out/lib/lotion/lotion $out/lib/lotion/chrome_crashpad_handler $out/lib/lotion/chrome-sandbox

        # Create wrapped binary with Wayland/Ozone flags
        mkdir -p $out/bin
        makeWrapper $out/lib/lotion/lotion $out/bin/lotion \
          --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
          --suffix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime=true}}"

        # Install icon
        for size in 16 32 48 128 256 512; do
          install -Dm644 ${icon} $out/share/icons/hicolor/''${size}x''${size}/apps/lotion.png
        done
        install -Dm644 ${icon} $out/share/pixmaps/lotion.png

        # Install desktop file with notion:// URL handler
        mkdir -p $out/share/applications
        cat > $out/share/applications/lotion.desktop << EOF
        [Desktop Entry]
        Name=Lotion
        Comment=Unofficial Notion.so Desktop App for Linux
        Exec=$out/bin/lotion %U
        Icon=lotion
        Type=Application
        Categories=Office;
        MimeType=x-scheme-handler/notion;
        StartupNotify=true
        StartupWMClass=Lotion
        EOF

        runHook postInstall
      '';

      meta = with lib; {
        description = "Unofficial Notion.so Desktop App for Linux";
        homepage = "https://github.com/puneetsl/lotion";
        license = licenses.mit;
        mainProgram = "lotion";
        platforms = ["x86_64-linux"];
      };
    };
in {
  home.packages = with pkgs; [
    wireguard-tools

    slack

    lotion

    (pkgs.jetbrains-plugins.lib.buildIdeWithPlugins pkgs.jetbrains.datagrip (with pkgs.jetbrains-plugins; [
      IdeaVIM
      com.intellij.ml.llm
      com.intellij.mcpServer
      aws.toolkit.core
      aws.toolkit
      com.github.catppuccin.jetbrains
    ]))
  ];
}
