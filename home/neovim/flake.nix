{
  description = "Neovim plugin sources";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake-enabled plugins (use their package outputs)
    blink-cmp = {
      url = "github:Saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lze = {
      url = "github:BirdeeHub/lze";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gx = {
      url = "github:chrishrb/gx.nvim";
      flake = false;
    };

    # Plain source plugins (flake = false)
    plenary = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    nui = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };
    nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    SchemaStore = {
      url = "github:b0o/SchemaStore.nvim";
      flake = false;
    };
    nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };
    nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    catppuccin = {
      url = "github:catppuccin/nvim";
      flake = false;
    };
    tokyonight = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };
    lualine = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
    which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    noice = {
      url = "github:folke/noice.nvim";
      flake = false;
    };
    nvim-notify = {
      url = "github:rcarriga/nvim-notify";
      flake = false;
    };
    tabby = {
      url = "github:nanozuki/tabby.nvim";
      flake = false;
    };
    dropbar = {
      url = "github:Bekaboo/dropbar.nvim";
      flake = false;
    };
    auto-session = {
      url = "github:rmagatti/auto-session";
      flake = false;
    };
    snacks = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
    helpview = {
      url = "github:OXY2DEV/helpview.nvim";
      flake = false;
    };
    tabout = {
      url = "github:abecodes/tabout.nvim";
      flake = false;
    };
    colorful-menu = {
      url = "github:xzbdmw/colorful-menu.nvim";
      flake = false;
    };
    gitsigns = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    diffview = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };
    octo = {
      url = "github:pwntester/octo.nvim";
      flake = false;
    };
    flash = {
      url = "github:folke/flash.nvim";
      flake = false;
    };
    trouble = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    todo-comments = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    vim-matchup = {
      url = "github:andymass/vim-matchup";
      flake = false;
    };
    mini-icons = {
      url = "github:nvim-mini/mini.icons";
      flake = false;
    };
    mini-ai = {
      url = "github:nvim-mini/mini.ai";
      flake = false;
    };
    mini-files = {
      url = "github:nvim-mini/mini.files";
      flake = false;
    };
    mini-move = {
      url = "github:nvim-mini/mini.move";
      flake = false;
    };
    mini-surround = {
      url = "github:nvim-mini/mini.surround";
      flake = false;
    };
    conform = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    nvim-lint = {
      url = "github:mfussenegger/nvim-lint";
      flake = false;
    };
    lightbulb = {
      url = "github:kosayoda/nvim-lightbulb";
      flake = false;
    };
    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };
    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
      flake = false;
    };
    typescript-tools = {
      url = "github:pmizio/typescript-tools.nvim";
      flake = false;
    };
    undotree = {
      url = "github:jiaoshijie/undotree";
      flake = false;
    };
    markview = {
      url = "github:OXY2DEV/markview.nvim";
      flake = false;
    };
    codecompanion = {
      url = "github:olimorris/codecompanion.nvim";
      flake = false;
    };
    gatekeeper = {
      url = "github:augustocdias/gatekeeper.nvim";
      flake = false;
    };
    codesnap = {
      url = "github:mistricky/codesnap.nvim";
      flake = false;
    };
    codecompanion-spinner = {
      url = "github:franco-ruggeri/codecompanion-spinner.nvim";
      flake = false;
    };
    nvim-nio = {
      url = "github:nvim-neotest/nvim-nio";
      flake = false;
    };
    codecompanion-history = {
      url = "github:ravitemer/codecompanion-history.nvim";
      flake = false;
    };
    mcphub = {
      url = "github:ravitemer/mcphub.nvim";
      flake = false;
    };
    crates = {
      url = "github:Saecki/crates.nvim";
      flake = false;
    };
    refactoring = {
      url = "github:ThePrimeagen/refactoring.nvim";
      flake = false;
    };
    markdown-plus = {
      url = "github:yousefhadder/markdown-plus.nvim";
      flake = false;
    };
  };

  outputs = {...} @ inputs: {
    inherit inputs;
  };
}
