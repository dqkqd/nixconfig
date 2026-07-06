{
  description = "dqk NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix/release-26.05";

    nvim-nixos = {
      url = "github:dqkqd/nvim-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://nix-community.github.io/home-manager/faq/unstable.html
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    nixpkgs,
    nixos-hardware,
    home-manager,
    catppuccin,
    nixpkgs-unstable,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      legend = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./host/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
          home-manager.nixosModules.home-manager
          ({config, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              pkgsUnstable = import nixpkgs-unstable {
                inherit system;
                config = config.nixpkgs.config;
                overlays = config.nixpkgs.overlays;
              };
            };
            home-manager.users.dqk = {
              imports = [
                ./user/home.nix
                catppuccin.homeModules.catppuccin
              ];
            };
          })
        ];
      };
    };
  };
}
