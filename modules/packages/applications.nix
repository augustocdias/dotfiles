{den, ...}: {
  den.aspects.applications = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        cider-2
        kitty
        zed-editor
        imv
        peazip
        drawio
      ];
    };
  };
}
