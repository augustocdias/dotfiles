{...}: {
  services.fprintd.enable = true;

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger";
      accelSpeed = "1.0";
      accelProfile = "flat";
      disableWhileTyping = true;
    };
  };
}
