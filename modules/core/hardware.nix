{...}: {
  hardware.graphics.enable = true;
  hardware.i2c.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.power-profiles-daemon.enable = true;

  services.pipewire.wireplumber.extraConfig."99-disable-hdmi-audio" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_output.*HDMI*"; }
        ];
        actions.update-props = {
          "node.disabled" = true;
        };
      }
    ];
  };

  # Default to Speaker profile (index 2) on the Arrow Lake audio device.
  # Profile 1 (Headphones) has higher priority but only works with headphones
  # plugged in. Jack detection will auto-switch to Profile 1 when headphones
  # are connected.
  services.pipewire.wireplumber.extraConfig."98-default-speaker-profile" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "device.name" = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"; }
        ];
        actions.update-props = {
          "device.profile" = "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)";
        };
      }
    ];
  };

  services.udisks2.enable = true;
}
