# Input devices configuration
# Fingerprint reader and touchpad
{...}: {
  # Fingerprint reader support
  services.fprintd.enable = true;

  # Touchpad/trackpad support via libinput
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger";
      accelSpeed = "1.0"; # Max speed (-1.0 to 1.0)
      accelProfile = "flat";
      disableWhileTyping = true;
    };
  };
}
