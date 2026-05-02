{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          ./checks
          ./packages
          ./modules/flake-parts
          ./modules/flake-parts/internal
        ];

        systems = [ "x86_64-linux" ];

        flake = {
          flakeModules.default = import ./modules/flake-parts;
          nixosModules.default = import ./modules/nixos;
          homeModules.default = import ./modules/home-manager;
        };
      }
    );
}
