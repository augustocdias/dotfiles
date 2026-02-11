# User configuration
{pkgs, ...}: {
  # User Management
  users.mutableUsers = false;
  users.users.augusto = {
    isNormalUser = true;
    description = "Augusto";
    extraGroups = ["wheel" "networkmanager" "docker" "video" "render" "greeter" "libvirtd"];
    shell = pkgs.fish;
    hashedPasswordFile = "/etc/nixos/secrets/augusto-password";
  };

  # Enable AccountsService for profile pictures (used by DankMaterialShell)
  services.accounts-daemon.enable = true;

  # Set profile picture via AccountsService
  system.activationScripts.userIcon = ''
        mkdir -p /var/lib/AccountsService/users
        cat > /var/lib/AccountsService/users/augusto << 'EOF'
    [User]
    Icon=/home/augusto/media/avatar/luffy.png
    EOF
  '';

  # DankGreeter manual sync - ACL and group permissions
  system.activationScripts.dankGreeterSync = ''
    # Create greeter cache directory
    mkdir -p /var/cache/dms-greeter

    # Set ACL permissions for greeter to access user directories
    ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto || true
    ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto/.config || true
    ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto/.local || true
    ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto/.cache || true
    ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto/.local/state || true

    # Set group permissions on DMS directories
    if [ -d /home/augusto/.config/DankMaterialShell ]; then
      chgrp -R greeter /home/augusto/.config/DankMaterialShell || true
      chmod -R g+rX /home/augusto/.config/DankMaterialShell || true
    fi
    if [ -d /home/augusto/.local/state/DankMaterialShell ]; then
      chgrp -R greeter /home/augusto/.local/state/DankMaterialShell || true
      chmod -R g+rX /home/augusto/.local/state/DankMaterialShell || true
    fi
    if [ -d /home/augusto/.cache/quickshell ]; then
      chgrp -R greeter /home/augusto/.cache/quickshell || true
      chmod -R g+rX /home/augusto/.cache/quickshell || true
    fi
    if [ -d /home/augusto/.cache/DankMaterialShell ]; then
      chgrp -R greeter /home/augusto/.cache/DankMaterialShell || true
      chmod -R g+rX /home/augusto/.cache/DankMaterialShell || true
    fi

    # Create symlinks for greeter config
    ln -sf /home/augusto/.config/DankMaterialShell/settings.json /var/cache/dms-greeter/settings.json || true
    ln -sf /home/augusto/.local/state/DankMaterialShell/session.json /var/cache/dms-greeter/session.json || true
    ln -sf /home/augusto/.cache/DankMaterialShell/dms-colors.json /var/cache/dms-greeter/colors.json || true
  '';

  # Enable fish system-wide
  programs.fish.enable = true;
}
