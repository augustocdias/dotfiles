{den, ...}: {
  den.aspects.users = {
    nixos = {pkgs, ...}: {
      users.mutableUsers = false;
      users.users.augusto = {
        isNormalUser = true;
        description = "Augusto";
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "render"
          "greeter"
          "libvirtd"
          "i2c"
        ];
        hashedPasswordFile = "/etc/nixos/secrets/augusto-password";
      };

      services.accounts-daemon.enable = true;

      system.activationScripts.userIcon = ''
            mkdir -p /var/lib/AccountsService/users
            cat > /var/lib/AccountsService/users/augusto << 'EOF'
        [User]
        Icon=/home/augusto/media/avatar/luffy.png
        EOF
      '';

      # Grant the DMS greeter read access to user config dirs so it can
      # share theme/session state with the user's DMS shell instance.
      system.activationScripts.dankGreeterSync = ''
        mkdir -p /var/cache/dms-greeter

        ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto || true
        ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto/.config || true
        ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto/.local || true
        ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto/.cache || true
        ${pkgs.acl}/bin/setfacl -m u:greeter:x /home/augusto/.local/state || true

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

        ln -sf /home/augusto/.config/DankMaterialShell/settings.json /var/cache/dms-greeter/settings.json || true
        ln -sf /home/augusto/.local/state/DankMaterialShell/session.json /var/cache/dms-greeter/session.json || true
        ln -sf /home/augusto/.cache/DankMaterialShell/dms-colors.json /var/cache/dms-greeter/colors.json || true
      '';

      programs.fish.enable = true;
    };
  };
}
