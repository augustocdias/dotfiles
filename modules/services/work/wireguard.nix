{den, ...}: {
  den.aspects.wireguard = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.wireguard-tools];
    };
  };
}
