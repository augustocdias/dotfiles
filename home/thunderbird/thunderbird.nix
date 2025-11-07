# Thunderbird email client configuration
{
  config,
  pkgs,
  lib,
  ...
}: let
  extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

  extensionData = builtins.fromJSON (builtins.readFile ./extensions.json);

  # Build extension packages from fetched XPIs
  buildThunderbirdExtension = name: data:
    pkgs.stdenv.mkDerivation {
      pname = "thunderbird-extension-${name}";
      version = "1.0";

      src = pkgs.fetchurl {
        url = data.url;
        name = "${name}.xpi";
        sha256 = data.sha256;
      };

      dontUnpack = true;

      installPhase = ''
        mkdir -p "$out/share/mozilla/${extensionPath}"
        cp "$src" "$out/share/mozilla/${extensionPath}/${data.addonId}.xpi"
      '';
    };

  extensions = lib.mapAttrsToList buildThunderbirdExtension extensionData;
in {
  programs.thunderbird = {
    enable = true;

    profiles.default = {
      isDefault = true;

      settings = {
        # === Privacy & Security ===
        "privacy.donottrackheader.enabled" = true;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "signon.rememberSignons" = false;

        # === Appearance ===
        "ui.systemUsesDarkTheme" = 1;
        "browser.in-content.dark-mode" = true;

        # === Default App Check ===
        "mail.shell.checkDefaultClient" = false;
        "mail.shell.checkDefaultMail" = false;

        # === Languages (same as Firefox) ===
        "intl.accept_languages" = "en-US,en,pt-BR,pt,de";
        "intl.locale.requested" = "en-US,pt-BR,de";

        # === Spell Checker ===
        # Enable spell checking and set dictionaries
        "spellchecker.dictionary" = "en-US,pt-BR,de-DE";
        # Enable multi-language spell checking
        "spellchecker.dictionary.override" = "en-US,pt-BR,de-DE";
        # Enable inline spell check in compose
        "mail.spellcheck.inline" = true;
        # Use all available dictionaries
        "layout.spellcheckDefault" = 1;

        # === Search Engine - DuckDuckGo ===
        # Set DuckDuckGo as default search engine
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.selectedEngine" = "DuckDuckGo";
        "browser.search.order.1" = "DuckDuckGo";
        "browser.urlbar.placeholderName" = "DuckDuckGo";

        # === Downloads ===
        "browser.download.folderList" = 2;
        "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
        "browser.download.useDownloadDir" = true;

        # === Reading - Mark as read after 5 seconds ===
        "mailnews.mark_message_read.auto" = true;
        "mailnews.mark_message_read.delay" = true;
        "mailnews.mark_message_read.delay.interval" = 5;

        # === Compose ===
        "mail.identity.default.compose_html" = true;
        "mail.SpellCheckBeforeSend" = true;

        # === Calendar ===
        "calendar.timezone.local" = "Europe/Berlin";

        # === Misc ===
        "mailnews.start_page.enabled" = false;
        "extensions.autoDisableScopes" = 0;
      };

      # Declarative search engine configuration
      search = {
        force = true;
        default = "ddg";
        engines = {
          google.metaData.hidden = true;
          bing.metaData.hidden = true;
          amazondotcom-us.metaData.hidden = true;
          ebay.metaData.hidden = true;
          wikipedia.metaData.alias = "@wiki";
        };
      };

      inherit extensions;
    };
  };
}
