{pkgs, ...}: let
  icon = path: "${pkgs.papirus-icon-theme}/share/icons/Papirus/24x24/${path}.svg";
in {
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    settings = {
      icon_names = {
        media = [(icon "panel/drive-removable-media-usb-panel")];
        browse = [(icon "actions/document-open")];
        terminal = [(icon "apps/terminal")];
        mount = [(icon "actions/udiskie-mount")];
        unmount = [(icon "actions/udiskie-unmount")];
        unlock = [(icon "actions/udiskie-unlock")];
        lock = [(icon "actions/udiskie-lock")];
        eject = [(icon "actions/udiskie-eject")];
        detach = [(icon "actions/udiskie-detach")];
        delete = [(icon "actions/udiskie-eject")];
        quit = [(icon "actions/application-exit")];
        forget_password = [(icon "actions/edit-delete")];
        losetup = [(icon "actions/udiskie-mount")];
        checked = [(icon "symbolic/status/checkbox-checked-symbolic")];
        unchecked = [(icon "actions/checkbox")];
        submenu = [(icon "actions/udiskie-submenu")];
      };
    };
  };
}
