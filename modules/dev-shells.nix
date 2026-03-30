{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    neovimPkg = inputs.self.nixosConfigurations.laptop.config.home-manager.users.augusto.programs.neovim.finalPackage;
  in {
    devShells.nvim-dev = pkgs.mkShell {
      packages = [
        (pkgs.writeShellScriptBin "nvim" ''
          PLUGIN_DIR="''${NVIM_DEV_PLUGIN:-$PWD}"
          exec ${neovimPkg}/bin/nvim --cmd "lua vim.opt.rtp:prepend('$PLUGIN_DIR')" "$@"
        '')
      ];

      shellHook = ''
        echo "Neovim dev shell active"
        echo "Plugin dir: ''${NVIM_DEV_PLUGIN:-$PWD}"
      '';
    };
  };
}
