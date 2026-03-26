{
  pkgs,
  lib,
  ...
}: let
  # Derive SSH public key from GPG key at build time for authorized_keys
  gpgPublicKey = pkgs.fetchurl {
    url = "https://keys.openpgp.org/vks/v1/by-fingerprint/7D8396F74725A208D835CE3730E62A1E4F078650";
    hash = "sha256-v11agJZKThP3/rNN23vyTEwnOk8928JBDlER7Dub4Gc=";
  };

  sshAuthorizedKey =
    pkgs.runCommand "gpg-ssh-key" {
      nativeBuildInputs = [pkgs.gnupg];
    } ''
      export GNUPGHOME=$(mktemp -d)
      gpg --batch --import ${gpgPublicKey}
      gpg --export-ssh-key 7D8396F74725A208D835CE3730E62A1E4F078650 > $out
    '';
in {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "90%";

  networking.networkmanager.enable = true;
  networking.wireless.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  services.getty.autologinUser = "nixos";

  users.users.root.openssh.authorizedKeys.keyFiles = [sshAuthorizedKey];

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialHashedPassword = lib.mkForce null;
    password = lib.mkForce "nixos";
    openssh.authorizedKeys.keyFiles = [sshAuthorizedKey];
  };

  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    wget
    curl
    htop
    tree
    parted
    gptfdisk
    cryptsetup
    tpm2-tools
    libfido2
    mkpasswd
    fish
    util-linux
    jq
    networkmanager
    nixos-install-tools
    gnupg
  ];

  console = {
    font = "ter-v22n";
    packages = [pkgs.terminus_font];
  };

  environment.etc."post-install.fish" = {
    mode = "0755";
    text = builtins.readFile ./post-install.fish;
  };

  programs.bash.loginShellInit = ''
    clear
    echo ""
    echo "NixOS Installer ISO"
    echo "==================="
    echo ""
    echo "Commands:"
    echo "  install-local <host>  - Install locally (formats disk, installs NixOS)"
    echo "  post-install          - Run post-install setup (TPM, FIDO2, sops, etc.)"
    echo ""
    echo "For remote installs, use nixos-anywhere from another machine."
    echo ""
  '';

  environment.shellAliases = {
    post-install = "sudo fish /etc/post-install.fish";
    install-local = ''
      sh -c '
        HOST="$1"
        if [ -z "$HOST" ]; then
          echo "Usage: install-local <host-name>"
          echo "Available: laptop, raspi"
          exit 1
        fi
        REPO=/etc/nixos-installer/repo
        echo "Installing NixOS configuration: $HOST"
        echo "Running disko..."
        sudo nix run github:nix-community/disko/latest -- --mode destroy,format,mount --flake "$REPO#$HOST"
        echo "Copying repo to target..."
        sudo mkdir -p /mnt/home/augusto/nixos
        sudo cp -r "$REPO"/. /mnt/home/augusto/nixos/
        sudo mkdir -p /mnt/etc/nixos/secrets
        echo "Enter password for user augusto:"
        read -s PASS
        echo "$PASS" | sudo mkpasswd -m yescrypt -s | sudo tee /mnt/etc/nixos/secrets/augusto-password > /dev/null
        echo "Running nixos-install..."
        sudo nixos-install --flake "/mnt/home/augusto/nixos#$HOST" --no-root-password
        sudo chown -R 1000:100 /mnt/home/augusto
        echo ""
        echo "Installation complete. Run post-install for TPM/FIDO2 enrollment:"
        echo "  sudo nixos-enter --root /mnt -- fish /etc/post-install.fish --tpm --fido"
        echo "Then reboot."
      ' _ '';
  };
}
