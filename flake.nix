{
  description = "Omnivium — stepii's Neovim Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ##
    # Neovim plugins not tracked by nixpkgs or that require newer versions
    ##
    plugins-nvim-toggler = {
      url = "github:nguyenvukhang/nvim-toggler";
      flake = false;
    };
    plugins-nvim-better-n = {
      url = "github:jonatan-branting/nvim-better-n";
      flake = false;
    };
    plugins-telescope-luasnip = {
      url = "github:benfowler/telescope-luasnip.nvim";
      flake = false;
    };
    plugins-confirm-quit = {
      url = "github:yutkat/confirm-quit.nvim";
      flake = false;
    };
    plugins-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };
    plugins-pick-resession = {
      url = "github:scottmckendry/pick-resession.nvim";
      flake = false;
    };
    plugins-zen-mode = {
      url = "github:fidgetingbits/zen-mode.nvim?ref=fix-terminal";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      wrappers,
      flake-parts,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ wrappers.flakeModules.wrappers ];
      systems = nixpkgs.lib.platforms.all;

      perSystem =
        {
          system,
          config,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          packages = {
            # NOTE: reminder that the paths for this package are only used
            # when running `nix build .#full` for testing
            full = config.packages.neovim.wrap {
              settings = {
                devMode = true;
                neovide = true;
                terminalMode = true;
                unwrappedConfig = "/home/stepii/src/nix/neovim";
              };
            };
            basic = config.packages.neovim.wrap {
              settings = {
                neovide = true;
              };
            };
          };
        };

      flake.wrappers = {
        neovim = lib.modules.importApply ./module.nix inputs;
        default = self.wrapperModules.neovim;
      };
    };
}
