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
    ###
    # Neovim plugins from outside nixpkgs, either for fetching latest source or
    # because there is no package yet. See nvim-lib.neovimPlugins in module.nix
    ###
    # plugins-lze = {
    #   url = "github:BirdeeHub/lze";
    #   flake = false;
    # };
    # plugins-lzextras = {
    #   url = "github:BirdeeHub/lzextras";
    #   flake = false;
    # };
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
