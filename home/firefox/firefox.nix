# Firefox browser configuration
{...}: let
  extensionData = builtins.fromJSON (builtins.readFile ./extensions.json);
  extensionNames = builtins.attrNames extensionData;

  # Generate policies to auto-install extensions
  extensionPolicies = builtins.listToAttrs (map (name: {
      name = extensionData.${name}.addonId;
      value = {
        installation_mode = "force_installed";
        install_url = extensionData.${name}.url;
      };
    })
    extensionNames);
in {
  programs.firefox = {
    enable = true;

    policies = {
      ExtensionSettings = extensionPolicies;
      DontCheckDefaultBrowser = true;
      DisableTelemetry = true;
      DisablePocket = true;
    };

    profiles.default = {
      isDefault = true;

      settings = {
        # Session Restore
        "browser.startup.page" = 3;
        "browser.sessionstore.resume_from_crash" = true;

        # Default Browser
        "browser.shell.checkDefaultBrowser" = false;

        # Appearance
        "ui.systemUsesDarkTheme" = 1;
        "browser.in-content.dark-mode" = true;
        "browser.theme.content-theme" = 0;

        # Languages
        "intl.accept_languages" = "en-US,en,pt-BR,pt,de";
        "intl.locale.requested" = "en-US,pt-BR,de";

        # Search Engine
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.order.1" = "DuckDuckGo";
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "browser.urlbar.placeholderName.private" = "DuckDuckGo";
        "browser.search.suggest.enabled" = true;
        "browser.urlbar.suggest.searches" = true;

        # Disable AI Features
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.sidebar" = false;
        "browser.tabs.groups.ai.enabled" = false;
        "browser.tabs.groups.ai.suggest" = false;

        # Privacy - Tracking Protection
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.fingerprintingProtection" = true;

        # Privacy - Do Not Track & Global Privacy Control
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.globalprivacycontrol.functionality.enabled" = true;

        # Privacy - Cookies
        "network.cookie.cookieBehavior" = 1;
        "privacy.partition.network_state.ocsp_cache" = true;

        # Privacy - HTTPS
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;

        # Disable Password Manager (using 1Password)
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;
        "signon.management.page.breach-alerts.enabled" = false;
        "signon.firefoxRelay.feature" = "disabled";

        # Disable Telemetry
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.coverage.opt-out" = true;
        "toolkit.coverage.endpoint.base" = "";
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

        # Disable Recommendations
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;

        # Disable Pocket
        "extensions.pocket.enabled" = false;

        # Disable Sponsored Content
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;

        # Enable userChrome customization
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Smooth scrolling
        "general.smoothScroll" = true;

        # Disable Form Autofill
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # Network Privacy
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.predictor.enabled" = false;

        # WebRTC Privacy
        "media.peerconnection.ice.default_address_only" = true;
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
    };
  };
}
