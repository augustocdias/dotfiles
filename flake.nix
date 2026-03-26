# This file is managed by flake-file. After editing module inputs,
# regenerate with: nix run .#write-flake
{
  description = "NixOS system with Hyprland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    den.url = "github:vic/den";
    flake-aspects.url = "github:vic/flake-aspects";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    flake-file.url = "github:vic/flake-file";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugins = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin-grub = {
      url = "github:catppuccin/grub/0a37ab19f654e77129b409fed371891c01ffd0b9";
      flake = false;
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sqlit = {
      url = "github:Maxteabag/sqlit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jetbrains-plugins = {
      url = "github:Janrupf/nix-jetbrains-plugin-repository";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Neovim plugins (nvim- prefix for selective updates) ---

    nvim-blink-cmp = {
      url = "github:Saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-blink-pairs = {
      url = "github:saghen/blink.pairs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-lze = {
      url = "github:BirdeeHub/lze";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-gx = {
      url = "github:chrishrb/gx.nvim";
      flake = false;
    };
    nvim-plenary = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    nvim-nui = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };
    nvim-nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    nvim-SchemaStore = {
      url = "github:b0o/SchemaStore.nvim";
      flake = false;
    };
    nvim-nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };
    nvim-nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    nvim-catppuccin = {
      url = "github:catppuccin/nvim";
      flake = false;
    };
    nvim-tokyonight = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    nvim-lualine = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
    nvim-which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    nvim-noice = {
      url = "github:folke/noice.nvim";
      flake = false;
    };
    nvim-nvim-notify = {
      url = "github:rcarriga/nvim-notify";
      flake = false;
    };
    nvim-tabby = {
      url = "github:nanozuki/tabby.nvim";
      flake = false;
    };
    nvim-dropbar = {
      url = "github:Bekaboo/dropbar.nvim";
      flake = false;
    };
    nvim-auto-session = {
      url = "github:rmagatti/auto-session";
      flake = false;
    };
    nvim-snacks = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
    nvim-helpview = {
      url = "github:OXY2DEV/helpview.nvim";
      flake = false;
    };
    nvim-tabout = {
      url = "github:abecodes/tabout.nvim";
      flake = false;
    };
    nvim-colorful-menu = {
      url = "github:xzbdmw/colorful-menu.nvim";
      flake = false;
    };
    nvim-gitsigns = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    nvim-diffview = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };
    nvim-octo = {
      url = "github:pwntester/octo.nvim";
      flake = false;
    };
    nvim-flash = {
      url = "github:folke/flash.nvim";
      flake = false;
    };
    nvim-trouble = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    nvim-todo-comments = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };
    nvim-vim-matchup = {
      url = "github:andymass/vim-matchup";
      flake = false;
    };
    nvim-mini-icons = {
      url = "github:nvim-mini/mini.icons";
      flake = false;
    };
    nvim-mini-ai = {
      url = "github:nvim-mini/mini.ai";
      flake = false;
    };
    nvim-mini-files = {
      url = "github:nvim-mini/mini.files";
      flake = false;
    };
    nvim-mini-move = {
      url = "github:nvim-mini/mini.move";
      flake = false;
    };
    nvim-mini-surround = {
      url = "github:nvim-mini/mini.surround";
      flake = false;
    };
    nvim-conform = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    nvim-nvim-lint = {
      url = "github:mfussenegger/nvim-lint";
      flake = false;
    };
    nvim-lightbulb = {
      url = "github:kosayoda/nvim-lightbulb";
      flake = false;
    };
    nvim-nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };
    nvim-nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    nvim-nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
      flake = false;
    };
    nvim-typescript-tools = {
      url = "github:pmizio/typescript-tools.nvim";
      flake = false;
    };
    nvim-undotree = {
      url = "github:jiaoshijie/undotree";
      flake = false;
    };
    nvim-markview = {
      url = "github:OXY2DEV/markview.nvim";
      flake = false;
    };
    nvim-codecompanion = {
      url = "github:olimorris/codecompanion.nvim";
      flake = false;
    };
    nvim-gatekeeper = {
      url = "github:augustocdias/gatekeeper.nvim";
      flake = false;
    };
    nvim-codesnap = {
      url = "github:mistricky/codesnap.nvim";
      flake = false;
    };
    nvim-codecompanion-spinner = {
      url = "github:franco-ruggeri/codecompanion-spinner.nvim";
      flake = false;
    };
    nvim-nvim-nio = {
      url = "github:nvim-neotest/nvim-nio";
      flake = false;
    };
    nvim-codecompanion-history = {
      url = "github:ravitemer/codecompanion-history.nvim";
      flake = false;
    };
    nvim-mcphub = {
      url = "github:ravitemer/mcphub.nvim";
      flake = false;
    };
    nvim-crates = {
      url = "github:Saecki/crates.nvim";
      flake = false;
    };
    nvim-refactoring = {
      url = "github:ThePrimeagen/refactoring.nvim";
      flake = false;
    };
    nvim-markdown-plus = {
      url = "github:yousefhadder/markdown-plus.nvim";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
