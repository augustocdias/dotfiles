{den, ...}: {
  den.aspects.applications = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        cider-2
        zed-editor
        imv
        peazip
        drawio
      ];
    };
  };
}
