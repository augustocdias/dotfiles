# Yubikey and smart card configuration
{pkgs, ...}: {
  # Smart card support for Yubikey
  services.pcscd.enable = true;

  # Yubikey udev rules
  services.udev.packages = [pkgs.yubikey-personalization];
}
