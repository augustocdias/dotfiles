{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugins.modules.default
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = false;

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = false;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;

    settings = {
      currentThemeName = "custom";
      currentThemeCategory = "registry";
      customThemeFile = "/home/augusto/.config/DankMaterialShell/themes/catppuccin/theme.json";
      registryThemeVariants = {
        catppuccin = {
          flavor = "mocha";
          accent = "blue";
        };
      };
      matugenScheme = "scheme-tonal-spot";
      runUserMatugenTemplates = true;
      cornerRadius = 6;
      popupTransparency = 1;
      dockTransparency = 1;
      widgetBackgroundColor = "s";
      widgetColorMode = "default";

      fontFamily = "Inter Variable";
      monoFontFamily = "MonaspiceRn Nerd Font Mono";
      fontWeight = 400;
      fontScale = 1;

      use24HourClock = true;
      showSeconds = false;
      useFahrenheit = false;
      windSpeedUnit = "kmh";

      animationSpeed = 1;
      customAnimationDuration = 500;

      wallpaperFillMode = "Fill";
      blurredWallpaperLayer = false;
      blurWallpaperOnOverview = false;

      showLauncherButton = true;
      showWorkspaceSwitcher = true;
      showFocusedWindow = true;
      showWeather = true;
      showMusic = true;
      showClipboard = true;
      showCpuUsage = true;
      showMemUsage = true;
      showCpuTemp = true;
      showGpuTemp = true;
      selectedGpuIndex = 0;
      showSystemTray = true;
      showClock = true;
      showNotificationButton = true;
      showBattery = true;
      showControlCenterButton = true;
      showCapsLockIndicator = true;
      showPrivacyButton = true;

      controlCenterShowNetworkIcon = true;
      controlCenterShowBluetoothIcon = true;
      controlCenterShowAudioIcon = true;
      controlCenterShowAudioPercent = false;
      controlCenterShowVpnIcon = true;
      controlCenterShowBrightnessIcon = false;
      controlCenterShowBrightnessPercent = false;
      controlCenterShowMicIcon = false;
      controlCenterShowMicPercent = false;
      controlCenterShowBatteryIcon = false;
      controlCenterShowPrinterIcon = false;
      controlCenterShowScreenSharingIcon = true;

      privacyShowMicIcon = true;
      privacyShowCameraIcon = true;
      privacyShowScreenShareIcon = true;

      controlCenterWidgets = [
        {
          id = "volumeSlider";
          enabled = true;
          width = 50;
        }
        {
          id = "brightnessSlider";
          enabled = true;
          width = 50;
        }
        {
          id = "wifi";
          enabled = true;
          width = 50;
        }
        {
          id = "bluetooth";
          enabled = true;
          width = 50;
        }
        {
          id = "audioInput";
          enabled = true;
          width = 50;
        }
        {
          id = "audioOutput";
          enabled = true;
          width = 50;
        }
        {
          id = "doNotDisturb";
          enabled = true;
          width = 50;
        }
        {
          id = "idleInhibitor";
          enabled = true;
          width = 50;
        }
        {
          id = "vpn";
          enabled = true;
          width = 50;
        }
        {
          id = "screenRecording";
          enabled = true;
          width = 50;
        }
      ];

      showWorkspaceIndex = true;
      showWorkspaceName = false;
      showWorkspacePadding = true;
      workspaceScrolling = false;
      showWorkspaceApps = false;
      maxWorkspaceIcons = 3;
      groupWorkspaceApps = true;
      workspaceFollowFocus = false;
      showOccupiedWorkspacesOnly = false;
      reverseScrolling = false;
      workspaceColorMode = "default";
      workspaceOccupiedColorMode = "none";
      workspaceUnfocusedColorMode = "default";
      workspaceUrgentColorMode = "default";
      workspaceFocusedBorderEnabled = false;
      workspaceFocusedBorderColor = "primary";
      workspaceFocusedBorderThickness = 2;

      waveProgressEnabled = true;
      scrollTitleEnabled = true;
      audioVisualizerEnabled = true;
      audioScrollMode = "volume";
      mediaSize = 1;

      clockCompactMode = false;
      focusedWindowCompactMode = false;
      runningAppsCompactMode = true;
      keyboardLayoutNameCompactMode = false;
      runningAppsCurrentWorkspace = true;
      runningAppsGroupByApp = false;

      centeringMode = "index";
      appLauncherViewMode = "list";
      spotlightModalViewMode = "list";
      sortAppsAlphabetically = false;
      appLauncherGridColumns = 4;
      spotlightCloseNiriOverview = true;
      niriOverviewOverlayEnabled = true;
      dankLauncherV2Size = "compact";
      dankLauncherV2BorderEnabled = false;
      dankLauncherV2BorderThickness = 2;
      dankLauncherV2BorderColor = "primary";
      dankLauncherV2ShowFooter = true;

      useAutoLocation = true;
      weatherEnabled = true;

      networkPreference = "wifi";
      iconTheme = "Papirus";

      cursorSettings = {
        theme = "System Default";
        size = 24;
        niri = {
          hideWhenTyping = false;
          hideAfterInactiveMs = 0;
        };
        hyprland = {
          hideOnKeyPress = true;
          hideOnTouch = false;
          inactiveTimeout = 0;
        };
        dwl.cursorHideTimeout = 0;
      };

      launcherLogoMode = "os";
      launcherLogoColorOverride = "primary";
      launcherLogoColorInvertOnMode = false;
      launcherLogoBrightness = 0.5;
      launcherLogoContrast = 1;
      launcherLogoSizeOffset = 0;

      notepadUseMonospace = true;
      notepadFontSize = 14;
      notepadShowLineNumbers = false;
      notepadTransparencyOverride = -1;
      notepadLastCustomTransparency = 0.7;

      soundsEnabled = true;
      useSystemSoundTheme = false;
      soundNewNotification = true;
      soundVolumeChanged = true;
      soundPluggedIn = true;

      acMonitorTimeout = 600;
      acLockTimeout = 180;
      acSuspendTimeout = 0;
      acSuspendBehavior = 0;

      batteryMonitorTimeout = 0;
      batteryLockTimeout = 0;
      batterySuspendTimeout = 0;
      batterySuspendBehavior = 0;
      batteryChargeLimit = 100;

      lockBeforeSuspend = true;
      loginctlLockIntegration = true;
      fadeToLockEnabled = true;
      fadeToLockGracePeriod = 5;
      fadeToDpmsEnabled = true;
      fadeToDpmsGracePeriod = 5;
      lockScreenShowPowerActions = true;
      lockScreenShowSystemIcons = true;
      lockScreenShowTime = true;
      lockScreenShowDate = true;
      lockScreenShowProfileImage = true;
      lockScreenShowPasswordField = true;
      lockScreenPowerOffMonitorsOnLock = false;
      enableFprint = false;
      maxFprintTries = 3;
      lockScreenActiveMonitor = "all";
      lockScreenInactiveColor = "#000000";
      lockScreenNotificationMode = 0;

      gtkThemingEnabled = true;
      qtThemingEnabled = true;
      syncModeWithPortal = true;
      terminalsAlwaysDark = false;
      runDmsMatugenTemplates = false;

      matugenTemplateGtk = true;
      matugenTemplateNiri = true;
      matugenTemplateHyprland = true;
      matugenTemplateMangowc = true;
      matugenTemplateQt5ct = true;
      matugenTemplateQt6ct = true;
      matugenTemplateFirefox = true;
      matugenTemplatePywalfox = true;
      matugenTemplateZenBrowser = true;
      matugenTemplateVesktop = true;
      matugenTemplateEquibop = true;
      matugenTemplateGhostty = true;
      matugenTemplateKitty = true;
      matugenTemplateFoot = true;
      matugenTemplateAlacritty = true;
      matugenTemplateNeovim = true;
      matugenTemplateWezterm = true;
      matugenTemplateDgop = true;
      matugenTemplateKcolorscheme = true;
      matugenTemplateVscode = true;
      matugenTemplateEmacs = true;

      showDock = false;
      dockAutoHide = false;
      dockSmartAutoHide = false;
      dockGroupByApp = false;
      dockOpenOnOverview = false;
      dockPosition = 1;
      dockSpacing = 4;
      dockBottomGap = 0;
      dockMargin = 0;
      dockIconSize = 40;
      dockIndicatorStyle = "circle";
      dockBorderEnabled = false;
      dockBorderColor = "surfaceText";
      dockBorderOpacity = 1;
      dockBorderThickness = 1;
      dockIsolateDisplays = false;
      dockLauncherEnabled = false;
      dockLauncherLogoMode = "apps";
      dockLauncherLogoSizeOffset = 0;
      dockLauncherLogoBrightness = 0.5;
      dockLauncherLogoContrast = 1;

      notificationOverlayEnabled = true;
      modalDarkenBackground = true;
      hideBrightnessSlider = false;
      notificationTimeoutLow = 5000;
      notificationTimeoutNormal = 5000;
      notificationTimeoutCritical = 0;
      notificationCompactMode = true;
      notificationPopupPosition = 0;
      notificationHistoryEnabled = true;
      notificationHistoryMaxCount = 50;
      notificationHistoryMaxAgeDays = 7;
      notificationHistorySaveLow = true;
      notificationHistorySaveNormal = true;
      notificationHistorySaveCritical = true;

      osdAlwaysShowValue = false;
      osdPosition = 5;
      osdVolumeEnabled = true;
      osdMediaVolumeEnabled = true;
      osdBrightnessEnabled = true;
      osdIdleInhibitorEnabled = true;
      osdMicMuteEnabled = true;
      osdCapsLockEnabled = true;
      osdPowerProfileEnabled = true;
      osdAudioOutputEnabled = true;

      powerActionConfirm = true;
      powerActionHoldDuration = 0.5;
      powerMenuActions = ["reboot" "logout" "poweroff" "lock" "suspend" "restart"];
      powerMenuDefaultAction = "logout";
      powerMenuGridLayout = false;

      customPowerActionLogout = "hyprshutdown";
      customPowerActionPowerOff = "hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'";
      customPowerActionReboot = "hyprshutdown -t 'Restarting...' --post-cmd 'reboot'";

      updaterHideWidget = true;
      updaterUseCustomCommand = false;

      displayNameMode = "system";
      screenPreferences.wallpaper = ["all"];

      barConfigs = [
        {
          id = "default";
          name = "Main Bar";
          enabled = true;
          position = 0;
          screenPreferences = ["all"];
          showOnLastDisplay = true;
          leftWidgets = [
            "launcherButton"
            "workspaceSwitcher"
            "focusedWindow"
            {
              id = "runningApps";
              enabled = true;
            }
          ];
          centerWidgets = [
            "music"
            {
              id = "clock";
              enabled = true;
              clockCompactMode = false;
            }
            "weather"
          ];
          rightWidgets = [
            {
              id = "systemTray";
              enabled = true;
            }
            {
              id = "clipboard";
              enabled = true;
            }
            {
              id = "cpuUsage";
              enabled = true;
            }
            {
              id = "memUsage";
              enabled = true;
            }
            {
              id = "battery";
              enabled = true;
            }
            {
              id = "notificationButton";
              enabled = true;
            }
            {
              id = "controlCenterButton";
              enabled = true;
              showAudioPercent = true;
              showBrightnessIcon = false;
            }
            {
              id = "sessionPower";
              enabled = true;
            }
          ];
          spacing = 0;
          innerPadding = -8;
          bottomGap = 0;
          transparency = 0.5;
          widgetTransparency = 0.81;
          squareCorners = true;
          noBackground = false;
          gothCornersEnabled = true;
          gothCornerRadiusOverride = false;
          gothCornerRadiusValue = 12;
          borderEnabled = false;
          borderColor = "surfaceText";
          borderOpacity = 1;
          borderThickness = 1;
          fontScale = 1;
          autoHide = false;
          autoHideDelay = 250;
          openOnOverview = false;
          visible = true;
          popupGapsAuto = true;
          popupGapsManual = 4;
        }
      ];

      desktopClockEnabled = false;
      desktopClockStyle = "analog";
      desktopClockTransparency = 0.8;
      desktopClockColorMode = "primary";
      desktopClockShowDate = true;
      desktopClockShowAnalogNumbers = false;
      desktopClockShowAnalogSeconds = true;
      desktopClockX = -1;
      desktopClockY = -1;
      desktopClockWidth = 280;
      desktopClockHeight = 180;
      desktopClockDisplayPreferences = ["all"];

      systemMonitorEnabled = false;
      systemMonitorShowHeader = true;
      systemMonitorTransparency = 0.8;
      systemMonitorColorMode = "primary";
      systemMonitorShowCpu = true;
      systemMonitorShowCpuGraph = true;
      systemMonitorShowCpuTemp = true;
      systemMonitorShowGpuTemp = false;
      systemMonitorShowMemory = true;
      systemMonitorShowMemoryGraph = true;
      systemMonitorShowNetwork = true;
      systemMonitorShowNetworkGraph = true;
      systemMonitorShowDisk = true;
      systemMonitorShowTopProcesses = false;
      systemMonitorTopProcessCount = 3;
      systemMonitorTopProcessSortBy = "cpu";
      systemMonitorGraphInterval = 60;
      systemMonitorLayoutMode = "auto";
      systemMonitorX = -1;
      systemMonitorY = -1;
      systemMonitorWidth = 320;
      systemMonitorHeight = 480;
      systemMonitorDisplayPreferences = ["all"];

      desktopWidgetInstances = [
        {
          id = "dw_1769172254836_7kkr5ii2j";
          widgetType = "systemMonitor";
          name = "System Monitor";
          enabled = true;
          config = {
            showHeader = true;
            transparency = 0.8;
            colorMode = "primary";
            customColor = "#ffffff";
            showCpu = true;
            showCpuGraph = true;
            showCpuTemp = true;
            showGpuTemp = false;
            showMemory = true;
            showMemoryGraph = true;
            showNetwork = true;
            showNetworkGraph = true;
            showDisk = true;
            showTopProcesses = true;
            topProcessCount = 3;
            topProcessSortBy = "cpu";
            layoutMode = "auto";
            graphInterval = 60;
            displayPreferences = ["all"];
            clickThrough = true;
            syncPositionAcrossScreens = true;
          };
          positions = {
            "Virtual-1" = {
              width = 320;
              height = 480;
              x = 0;
              y = 32.01953125;
            };
            "_synced" = {
              x = 0;
              y = 0.0400244140625;
              width = 320;
              height = 480;
            };
          };
        }
        {
          id = "dw_1769172259317_m4cnowlqm";
          widgetType = "dankDesktopWeather";
          name = "Weather";
          enabled = true;
          config = {
            displayPreferences = ["all"];
            showOnOverlay = false;
            clickThrough = true;
            syncPositionAcrossScreens = true;
            viewMode = "forecast";
          };
          positions = {
            "Virtual-1" = {
              width = 200;
              height = 200;
              x = 540;
              y = 300;
            };
            "_synced" = {
              x = 0.25311279296875;
              y = 0.0400341796875;
              width = 371.015625;
              height = 481.01171875;
            };
          };
        }
      ];

      configVersion = 5;
    };

    session = {
      wallpaperPath = "${config.home.homeDirectory}/media/wallpapers/807509.jpg";
      wallpaperCyclingEnabled = true;
      wallpaperCyclingMode = "interval";
      wallpaperCyclingInterval = 300; # 5 minutes
      wallpaperTransition = "random";
    };

    plugins = {
      commandRunner.enable = true;

      dankBatteryAlerts.enable = true;

      worldClock = {
        enable = false;
        settings = {
          timezones = [
            {
              timezone = "America/Sao_Paulo";
              label = "🇧🇷";
            }
            {
              timezone = "Europe/Berlin";
              label = "🇩🇪";
            }
          ];
        };
      };

      webSearch = {
        enable = true;
        settings = {
          defaultEngine = "duckduckgo";
        };
      };

      sessionPower.enable = true;

      emojiLauncher = {
        enable = true;
        settings = {
          noTrigger = false;
          trigger = ":";
        };
      };

      displaySettings.enable = true;

      dankDesktopWeather.enable = true;
    };
  };

  home.packages = [pkgs.inotify-tools];
}
