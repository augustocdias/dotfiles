{
  config,
  pkgs,
  lib,
  ...
}: let
  extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

  extensionData = builtins.fromJSON (builtins.readFile ./extensions.json);

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
        "privacy.donottrackheader.enabled" = true;
        "datareporting.healthreport.uploadEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "signon.rememberSignons" = false;

        "ui.systemUsesDarkTheme" = 1;
        "browser.in-content.dark-mode" = true;

        "mail.shell.checkDefaultClient" = false;
        "mail.shell.checkDefaultMail" = false;

        "intl.accept_languages" = "en-US,en,pt-BR,pt,de";
        "intl.locale.requested" = "en-US,pt-BR,de";

        "spellchecker.dictionary" = "en-US,pt-BR,de-DE";
        "spellchecker.dictionary.override" = "en-US,pt-BR,de-DE";
        "mail.spellcheck.inline" = true;
        "layout.spellcheckDefault" = 1;

        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.selectedEngine" = "DuckDuckGo";
        "browser.search.order.1" = "DuckDuckGo";
        "browser.urlbar.placeholderName" = "DuckDuckGo";

        "browser.download.folderList" = 2;
        "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
        "browser.download.useDownloadDir" = true;

        "mailnews.mark_message_read.auto" = true;
        "mailnews.mark_message_read.delay" = true;
        "mailnews.mark_message_read.delay.interval" = 5;

        "mail.identity.default.compose_html" = true;
        "mail.SpellCheckBeforeSend" = true;

        "calendar.timezone.local" = "Europe/Berlin";

        "mailnews.start_page.enabled" = false;
        "extensions.autoDisableScopes" = 0;
      };

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
