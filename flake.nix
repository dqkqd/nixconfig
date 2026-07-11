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

    fwupdOverlay = final: prev: {
      fwupd = prev.fwupd.overrideAttrs (old: rec {
        version = "2.1.6";
        src = prev.fetchFromGitHub {
          owner = "fwupd";
          repo = "fwupd";
          rev = version;
          hash = "sha256-K8n1rPiLuHDybWPoAUQA7RY4J+Ga1fwNiaj48fHAh9A=";
        };

        patches =
          builtins.filter (
            p:
              !(prev.lib.strings.hasInfix "0004-Get-the-efi-app-from-fwupd-efi" (baseNameOf (toString p)))
          )
          old.patches;

        mesonFlags =
          old.mesonFlags
          ++ [
            (prev.lib.mesonOption "efi_app_location" "${prev.fwupd-efi}/libexec/fwupd/efi")
          ];
      });
    };
  in {
    nixosConfigurations = {
      legend = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          pkgsUnstable = import nixpkgs-unstable {
            inherit system;
            overlays = [fwupdOverlay];
          };
        };
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
                overlays = config.nixpkgs.overlays ++ [fwupdOverlay];
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
