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
    plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, wrappers, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ wrappers.flakeModules.wrappers ];
      systems = nixpkgs.lib.platforms.all;

      perSystem = { pkgs, config, ... }: {
        _module.args.pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        packages = {
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
        neovim = (import ./module.nix) inputs;
        default = self.wrapperModules.neovim;
      };
    };
}
